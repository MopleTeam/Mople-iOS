//
//  TransferMeetViewModel.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import Foundation
import Combine
import RxCombine

@MainActor
final class TransferMeetViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var members: [MemberInfo] = []
    @Published var isLoading = false
    @Published var showError = false
    @Published var showSuccessAlert = false
    @Published var errorMessage = ""
    
    // MARK: - Private Properties
    private let meet: Meet
    private let fetchMemberListUseCase: FetchMemberList
    private let transferUseCase: TransferMeet
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(meet: Meet, 
         fetchMemberListUseCase: FetchMemberList,
         transferUseCase: TransferMeet) {
        self.meet = meet
        self.fetchMemberListUseCase = fetchMemberListUseCase
        self.transferUseCase = transferUseCase
        fetchMembers()
    }
    
    // MARK: - Fetch Members
    func fetchMembers() {
        guard let meetId = meet.meetSummary?.id else { return }
        
        isLoading = true
        
        // 모임 멤버 리스트 조회 (RxSwift → Combine)
        fetchMemberListUseCase.execute(type: .meet(id: meetId), cursor: nil)
            .publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    }
                },
                receiveValue: { [weak self] page in
                    guard let self = self else { return }
                    // 자신을 제외한 멤버 필터링
                    let currentUserId = UserInfoStorage.shared.userInfo?.id
                    self.members = page.content.filter { $0.memberId != currentUserId }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Transfer Meet
    func transferMeet(to memberId: Int) {
        guard let meetId = meet.meetSummary?.id else { return }
        
        isLoading = true
        
        // RxSwift Observable → Combine Publisher (RxCombine 사용)
        transferUseCase.execute(meetId: meetId, newHostId: memberId)
            .publisher  // 🔥 RxCombine이 자동으로 Observable → Publisher 변환!
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    switch completion {
                    case .finished:
                        break
                    case .failure(let error):
                        self.errorMessage = error.localizedDescription
                        self.showError = true
                    }
                },
                receiveValue: { [weak self] _ in
                    self?.showSuccessAlert = true
                }
            )
            .store(in: &cancellables)
    }
}
