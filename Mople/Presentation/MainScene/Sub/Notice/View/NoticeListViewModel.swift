//
//  NoticeListViewModel.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import Foundation
import Domain

// 공지 리스트 화면의 상태 머신.
// API 1회 호출로 전체 공지를 모두 받아두고, 탭 전환은 로컬 필터링으로만 처리한다 (명세 요구사항).
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
    }

    // MARK: - Published State
    @Published var notices: [Notice] = []
    @Published var selectedFilter: Filter = .all
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""

    // MARK: - Derived
    // 선택된 탭 기준으로 노출할 공지 리스트. 고정 공지는 항상 상단.
    var filteredNotices: [Notice] {
        let filtered: [Notice]
        switch selectedFilter {
        case .all:
            filtered = notices
        case .custom:
            filtered = notices.filter { $0.type == .custom }
        case .system:
            filtered = notices.filter { $0.type == .system }
        }
        return filtered.sorted { lhs, rhs in
            if lhs.isPinned != rhs.isPinned { return lhs.isPinned }
            let l = lhs.createdAt ?? .distantPast
            let r = rhs.createdAt ?? .distantPast
            return l > r
        }
    }

    let meetId: Int
    let isCreator: Bool

    // MARK: - Dependencies
    private let fetchListUseCase: FetchNoticeList
    private let togglePinUseCase: TogglePinNotice
    private weak var coordinator: NoticeFlowCoordination?
    private var pageInfo: PageInfo?
    private var isFetching = false

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

        Task { await self.loadInitial() }

        // 공지 생성/수정/삭제 후 발행되는 알림을 받아 리스트 reload
        // (Closure observer는 self를 capture하지 않고 토큰만 보관)
        self.updateToken = NotificationCenter.default.addObserver(
            forName: .noticeUpdated,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.loadInitial()
            }
        }
    }

    deinit {
        if let token = updateToken {
            NotificationCenter.default.removeObserver(token)
        }
    }

    // 알림 구독 토큰 (deinit에서 해제)
    private var updateToken: NSObjectProtocol?

    // MARK: - Loading
    func loadInitial() async {
        guard !isFetching else { return }
        isFetching = true
        isLoading = true
        defer { isFetching = false; isLoading = false }

        do {
            let page = try await fetchListUseCase.execute(meetId: meetId,
                                                          size: nil,
                                                          cursor: nil)
            self.notices = page.content
            self.pageInfo = page.info
        } catch {
            self.errorMessage = error.localizedDescription
            self.showError = true
        }
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
    // 이렇게 하면:
    //  - Mock UseCase가 type을 항상 .custom으로 반환하는 한계를 회피
    //  - 실제 서버 응답이 일부 필드를 누락해도 안전
    //  - 의미상 옳음(토글 액션의 책임 범위 밖 필드는 건드리지 않음)
    func togglePin(_ notice: Notice) {
        guard isCreator, let noticeId = notice.noticeId else { return }
        Task { [weak self] in
            guard let self else { return }
            do {
                let updated = try await self.togglePinUseCase.execute(
                    noticeId: noticeId,
                    isCurrentlyPinned: notice.isPinned
                )
                if let idx = self.notices.firstIndex(where: { $0.noticeId == updated.noticeId }) {
                    let existing = self.notices[idx]
                    self.notices[idx] = Notice(
                        noticeId: existing.noticeId,
                        version: updated.version ?? existing.version,
                        meetId: existing.meetId,
                        type: existing.type,
                        content: existing.content,
                        isPinned: updated.isPinned,
                        createdAt: existing.createdAt
                    )
                }
            } catch {
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
}
