//
//  TransferMeetListViewModel.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import Foundation
import Domain
import Combine
import RxSwift
import RxCombine

@MainActor
final class TransferMeetListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var meets: [Meet] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var errorMessage = ""
    // MARK: - Computed Properties
    
    /// 멤버가 2명 이상인 모임만 필터링 (양도 가능한 모임)
    var transferableMeets: [Meet] {
        return meets.filter { ($0.memberCount ?? 0) >= 2 }
    }
    
    /// 페이징 가능 여부
    var canLoadMore: Bool {
        return pageInfo?.hasNext ?? false
    }
    
    // MARK: - Private Properties
    private let fetchMyHostMeetsUseCase: FetchMyHostMeets
    private let deleteAccountUseCase: DeleteAccount
    private weak var coordinator: TransferMeetFlowCoordination?
    private var cancellables = Set<AnyCancellable>()

    // 페이징 정보
    private var pageInfo: PageInfo?
    private var isFetching = false

    // MARK: - Initialization
    init(fetchMyHostMeetsUseCase: FetchMyHostMeets,
         deleteAccountUseCase: DeleteAccount,
         coordinator: TransferMeetFlowCoordination? = nil) {
        self.fetchMyHostMeetsUseCase = fetchMyHostMeetsUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
        self.coordinator = coordinator

        fetchMeets()
        observeMeetUpdates()
    }

    // MARK: - Observe Meet Updates
    private func observeMeetUpdates() {
        // NotificationCenter에서 Meet 업데이트 구독 (RxSwift → Combine)
        NotificationManager.shared.addMeetObservable()
            .publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("✅ Meet notification stream finished")
                    case .failure(let error):
                        print("❌ Meet notification error: \(error)")
                    }
                },
                receiveValue: { [weak self] payload in
                    guard let self = self else { return }
                    
                    switch payload {
                    case .updated(let updatedMeet):
                        self.removeMeetAfterTransfer(updatedMeet)
                    default:
                        break
                    }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Fetch Meets
    func fetchMeets() {
        // 중복 요청 방지
        guard !isFetching else {
            print("⚠️ 이미 fetch 요청 중입니다.")
            return
        }
        
        // 더 이상 가져올 데이터가 없는 경우
        if let pageInfo = pageInfo, !pageInfo.hasNext {
            print("✅ 더 이상 가져올 모임이 없습니다.")
            return
        }
        
        isFetching = true
        
        // 초기 로딩 vs 페이징 로딩 구분
        if pageInfo == nil {
            isLoading = true
        }
        
        let cursor = pageInfo?.nextCursor

        // async throws UseCase 호출
        Task { [weak self] in
            guard let self else { return }
            do {
                let page = try await self.fetchMyHostMeetsUseCase.execute(cursor: cursor)
                self.isFetching = false
                self.isLoading = false

                // 페이징 정보 저장
                self.pageInfo = page.info

                // 기존 모임에 새 모임 추가 (중복 방지)
                let existingIds = Set(self.meets.compactMap { $0.meetSummary?.id })
                let uniqueNewMeets = page.content.filter { meet in
                    guard let meetId = meet.meetSummary?.id else { return false }
                    return !existingIds.contains(meetId)
                }
                self.meets.append(contentsOf: uniqueNewMeets)

                print("📄 모임 로드 완료: 총 \(self.meets.count)개 / hasNext: \(page.info?.hasNext ?? false)")
                print("📋 양도 가능한 모임: \(self.transferableMeets.count)개")
            } catch {
                self.isFetching = false
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    // MARK: - Load More
    func loadMoreMeetsIfNeeded() {
        fetchMeets()
    }
    
    // MARK: - Check Transfer Status
    
    /// 특정 모임이 양도 완료되었는지 확인
    func isTransferred(meet: Meet) -> Bool {
        let currentUserId = UserInfoStorage.shared.userInfo?.id
        return meet.creatorId != currentUserId
    }
    
    // MARK: - Remove Meet After Transfer

    /// 양도 완료된 모임을 리스트에서 제거
    private func removeMeetAfterTransfer(_ updatedMeet: Meet) {
        meets.removeAll { $0.meetSummary?.id == updatedMeet.meetSummary?.id }
    }
    
    // MARK: - Navigation
    
    /// 양도할 모임 선택 (Coordinator로 Navigation)
    func selectMeetForTransfer(_ meet: Meet) {
        coordinator?.showTransferMeet(meet: meet)
    }
    
  
    func proceedToDeleteAccount() {
        guard !isLoading else { return }
        isLoading = true

        // async throws UseCase 호출
        Task { [weak self] in
            guard let self else { return }
            do {
                try await self.deleteAccountUseCase.execute()
                self.isLoading = false
                // 유저 데이터 초기화
                KeychainStorage.shared.deleteToken()
                UserInfoStorage.shared.deleteEnitity()
                UserDefaults.deleteFCMToken()
                // 메인플로우 종료 → 로그인 화면
                self.coordinator?.endMainFlow()
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
    
    /// 플로우 종료 (뒤로가기)
    func dismissFlow() {
        coordinator?.endFlow()
    }
}
