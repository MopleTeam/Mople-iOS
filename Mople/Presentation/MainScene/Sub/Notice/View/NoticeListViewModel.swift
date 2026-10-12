//
//  NoticeListViewModel.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import Foundation
import Domain
import Data   // DataRequestError.isHandledError 사용 (취소/이미 처리된 에러 필터)

// 공지 리스트 화면의 상태 머신.
// 탭(전체/모임공지/시스템)마다 서버 필터(type)로 별도 조회 + 커서 페이지네이션.
// 탭별 상태(로드된 공지/커서/로드여부)를 캐시해 두어, 탭을 전환해도 이미 로드한 페이지가 유지된다.
@MainActor
final class NoticeListViewModel: ObservableObject {

    // MARK: - Filter Tab
    enum Filter: Int, CaseIterable {
        case all
        case custom
        case system

        var title: String {
            switch self {
            case .all: return "전체"
            case .custom: return "모임공지"
            case .system: return "시스템"
            }
        }

        // 서버 필터 파라미터. 전체는 nil(파라미터 미전송).
        var noticeType: NoticeType? {
            switch self {
            case .all: return nil
            case .custom: return .custom
            case .system: return .system
            }
        }
    }

    // MARK: - Per-Tab State
    // 탭 전환 시에도 로드된 페이지/커서를 유지하기 위한 탭별 캐시.
    private struct TabState {
        var notices: [Notice] = []
        var pageInfo: PageInfo?
        var hasLoaded = false
    }

    // MARK: - Published State
    // notices: 현재 선택된 탭의 표시용 리스트(고정 우선 + 최신순 정렬 반영).
    @Published private(set) var notices: [Notice] = []
    @Published var selectedFilter: Filter = .all
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    let meetId: Int
    let isCreator: Bool

    // MARK: - Dependencies
    private let fetchListUseCase: FetchNoticeList
    private let togglePinUseCase: TogglePinNotice
    private weak var coordinator: NoticeFlowCoordination?

    // 탭별 캐시 (전체/모임공지/시스템)
    private var states: [Filter: TabState] = [:]
    // 탭별 조회 진행 여부. 첫 페이지/새로고침/페이징을 통틀어 하나의 가드로 중복 요청을 막는다
    // (기존 뷰의 단일 isFetching과 동일 역할). 탭마다 독립이라 탭 전환 중 로드가 서로를 막지 않는다.
    private var fetchingTabs: Set<Filter> = []
    private var updateToken: NSObjectProtocol?

    init(meetId: Int,
         isCreator: Bool,
         fetchListUseCase: FetchNoticeList,
         togglePinUseCase: TogglePinNotice,
         coordinator: NoticeFlowCoordination?) {
        self.meetId = meetId
        self.isCreator = isCreator
        self.fetchListUseCase = fetchListUseCase
        self.togglePinUseCase = togglePinUseCase
        self.coordinator = coordinator

        // 최초 진입: 현재 탭(전체) 첫 페이지 로드
        Task { await self.loadFirstPageIfNeeded() }

        // 공지 생성/수정/삭제 후 발행되는 알림 → 모든 탭 캐시 무효화 후 현재 탭만 재로드
        // (생성/삭제는 여러 탭에 영향을 주므로 캐시 전체를 버리는 게 안전)
        self.updateToken = NotificationCenter.default.addObserver(
            forName: .noticeUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.invalidateAllAndReload()
            }
        }
    }

    deinit {
        if let token = updateToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    // MARK: - Sorting
    // 고정 공지는 항상 상단, 그 외는 최신순.
    private func sortedForDisplay(_ list: [Notice]) -> [Notice] {
        return list.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
            let l = lhs.createdAt ?? .distantPast
            let r = rhs.createdAt ?? .distantPast
            return l > r
        }
    }

    // MARK: - Filter Switch
    // 탭 전환: 캐시가 있으면 즉시 표시(API 미호출), 없으면 첫 페이지를 로드한다.
    func selectFilter(_ filter: Filter) {
        guard filter != selectedFilter else { return }
        selectedFilter = filter
        // 캐시된 데이터를 즉시 표시 (없으면 빈 상태 → 아래 로드에서 채움)
        notices = sortedForDisplay(states[filter]?.notices ?? [])
        Task { await loadFirstPageIfNeeded() }
    }

    // MARK: - Loading (첫 페이지)
    // 아직 로드하지 않은 탭이면 첫 페이지 로드. 이미 로드된 탭은 캐시 유지(재조회 안 함).
    func loadFirstPageIfNeeded() async {
        let filter = selectedFilter
        if states[filter]?.hasLoaded == true { return }
        await loadFirstPage(filter: filter, showLoadingIndicator: true)
    }

    // 당겨서 새로고침: 현재 탭 첫 페이지부터 다시 로드(커서 리셋).
    // 블로킹 로더(isLoading)는 끈다 — 켜면 터치 차단이 refresh 제스처를 취소시킨다(상세 화면과 동일 패턴).
    func refresh() async {
        await loadFirstPage(filter: selectedFilter, showLoadingIndicator: false)
    }

    // 특정 탭의 첫 페이지 로드 후 캐시에 저장. 로드 중 탭이 바뀌었을 수 있으니
    // 결과는 항상 해당 탭 캐시에 쓰고, 지금도 그 탭이 선택돼 있을 때만 화면(notices)에 반영한다.
    private func loadFirstPage(filter: Filter, showLoadingIndicator: Bool) async {
        guard !fetchingTabs.contains(filter) else { return }
        fetchingTabs.insert(filter)
        if showLoadingIndicator { isLoading = true }
        defer {
            fetchingTabs.remove(filter)
            if showLoadingIndicator { isLoading = false }
        }

        do {
            let page = try await fetchListUseCase.execute(meetId: meetId,
                                                          type: filter.noticeType,
                                                          size: nil,
                                                          cursor: nil)
            var state = states[filter] ?? TabState()
            state.notices = page.content
            state.pageInfo = page.info
            state.hasLoaded = true
            states[filter] = state

            if filter == selectedFilter {
                notices = sortedForDisplay(page.content)
            }
        } catch {
            // 이미 처리된(.handled) 에러(요청 취소 등)는 alert를 띄우지 않는다.
            guard !DataRequestError.isHandledError(err: error) else { return }
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    // MARK: - Pagination
    // 바닥에 닿기 전 미리 로드 — 기존 UIKit 리스트(isBottom(threshold:50))와 동일한 "선(先) 프리페치" 방식.
    // 마지막 셀을 기다리지 않고, 끝에서 prefetchDistance번째 셀이 나타나면 다음 페이지를 이어 로드한다.
    // (중복 요청은 fetchingTabs 가드가 막는다 = UIKit throttle 역할)
    private let prefetchDistance = 5

    func loadMoreIfNeeded(currentItem: Notice) {
        let filter = selectedFilter
        guard let info = states[filter]?.pageInfo, info.hasNext, !fetchingTabs.contains(filter) else { return }
        guard let idx = notices.firstIndex(where: { $0.noticeId == currentItem.noticeId }) else { return }
        // 끝에서 prefetchDistance칸 이내에 진입하면 미리 로드
        guard idx >= notices.count - prefetchDistance else { return }
        Task { await loadMore(filter: filter) }
    }

    private func loadMore(filter: Filter) async {
        guard let cursor = states[filter]?.pageInfo?.nextCursor,
              !fetchingTabs.contains(filter) else { return }
        fetchingTabs.insert(filter)
        defer { fetchingTabs.remove(filter) }

        do {
            let page = try await fetchListUseCase.execute(meetId: meetId,
                                                          type: filter.noticeType,
                                                          size: nil,
                                                          cursor: cursor)
            var state = states[filter] ?? TabState()
            // noticeId 기준 중복 제거 후 append (커서 경계 중복 방지)
            let existingIds = Set(state.notices.compactMap { $0.noticeId })
            let fresh = page.content.filter { notice in
                notice.noticeId.map { !existingIds.contains($0) } ?? true
            }
            state.notices.append(contentsOf: fresh)
            state.pageInfo = page.info
            states[filter] = state

            if filter == selectedFilter {
                notices = sortedForDisplay(state.notices)
            }
        } catch {
            guard !DataRequestError.isHandledError(err: error) else { return }
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
    }

    // MARK: - Cache Invalidation
    // 공지 생성/수정/삭제 알림 수신 시: 모든 탭 캐시를 버리고 현재 탭만 즉시 재로드.
    // 나머지 탭은 다음 진입 시 loadFirstPageIfNeeded로 다시 로드된다.
    private func invalidateAllAndReload() {
        states.removeAll()
        Task { await loadFirstPage(filter: selectedFilter, showLoadingIndicator: true) }
    }

    // MARK: - Actions
    func selectNotice(_ notice: Notice) {
        guard notice.noticeId != nil else { return }
        coordinator?.pushNoticeDetail(notice: notice, isCreator: isCreator)
    }

    func tapCompose() {
        coordinator?.pushComposeView()
    }

    func dismissFlow() {
        coordinator?.endFlow()
    }

    // MARK: - Pin Toggle
    // 모임장이 swipe action으로 호출.
    // togglePin은 의미상 isPinned/version 외 필드(type/content/createdAt 등)를 바꾸지 않으므로
    // 응답을 통째로 덮어쓰지 않고 기존 Notice에 isPinned/version만 머지한다.
    // 캐시된 모든 탭에서 해당 공지를 갱신해, 탭을 전환해도 고정 상태가 일관되게 유지된다.
    func togglePin(_ notice: Notice) {
        guard isCreator, let noticeId = notice.noticeId else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                let updated = try await self.togglePinUseCase.execute(
                    noticeId: noticeId,
                    isCurrentlyPinned: notice.isPinned
                )
                self.applyPinUpdate(noticeId: noticeId, isPinned: updated.isPinned, version: updated.version)
                // 모임상세 화면이 구독해서 pinnedNotice를 갱신할 수 있도록 알림 발행
                if let merged = self.states[self.selectedFilter]?.notices.first(where: { $0.noticeId == noticeId }) {
                    NotificationManager.shared.postItem(NoticePayload.updated(merged), from: self)
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    // 캐시된 모든 탭에서 해당 공지의 고정 상태/버전만 머지 후, 현재 탭 표시 갱신.
    private func applyPinUpdate(noticeId: Int, isPinned: Bool, version: Int?) {
        for (filter, var state) in states {
            guard let idx = state.notices.firstIndex(where: { $0.noticeId == noticeId }) else { continue }
            let existing = state.notices[idx]
            state.notices[idx] = Notice(
                noticeId: existing.noticeId,
                version: version ?? existing.version,
                meetId: existing.meetId,
                type: existing.type,
                content: existing.content,
                writer: existing.writer,
                isPinned: isPinned,
                createdAt: existing.createdAt
            )
            states[filter] = state
        }
        notices = sortedForDisplay(states[selectedFilter]?.notices ?? [])
    }
}
