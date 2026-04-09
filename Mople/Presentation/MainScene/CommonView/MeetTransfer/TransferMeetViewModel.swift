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
    @Published var searchText = ""
    @Published var isLoading = false  // 초기 로딩 (전체 화면 로딩)
    @Published var showError = false
    @Published var shouldDismiss = false
    @Published var errorMessage = ""
    
    // MARK: - Computed Properties
    var filteredMembers: [MemberInfo] {
        if searchText.isEmpty {
            return members
        }
        return members.filter { member in
            member.nickname?.localizedCaseInsensitiveContains(searchText) ?? false
        }
    }
    
    var canLoadMore: Bool {
        return pageInfo?.hasNext ?? false
    }
    
    // MARK: - Private Properties
    private var meet: Meet
    private let fetchMemberListUseCase: FetchMemberList
    private let transferUseCase: TransferMeet
    private var cancellables = Set<AnyCancellable>()
    
    // 페이징 정보
    private var pageInfo: PageInfo?
    private var isFetching = false  // 중복 요청 방지
    
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
        
        // 중복 요청 방지
        guard !isFetching else {
            print("⚠️ 이미 fetch 요청 중입니다.")
            return
        }
        
        // 더 이상 가져올 데이터가 없는 경우
        if let pageInfo = pageInfo, !pageInfo.hasNext {
            print("✅ 더 이상 가져올 멤버가 없습니다.")
            return
        }
        
        isFetching = true
        
        // 🔥 초기 로딩 vs 페이징 로딩 구분
        if pageInfo == nil {
            isLoading = true  // 전체 화면 로딩
        }
        
        let cursor = pageInfo?.nextCursor
        
        // 모임 멤버 리스트 조회 (RxSwift → Combine)
        fetchMemberListUseCase.execute(type: .meet(id: meetId), cursor: cursor)
            .publisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isFetching = false
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
                    
                    // 페이징 정보 저장
                    self.pageInfo = page.info
                    
                    // 자신을 제외한 멤버 필터링
                    let currentUserId = UserInfoStorage.shared.userInfo?.id
                    let newMembers = page.content.filter { $0.memberId != currentUserId }
                    
                    // 기존 멤버에 새 멤버 추가 (중복 방지)
                    let existingIds = Set(self.members.map { $0.memberId })
                    let uniqueNewMembers = newMembers.filter { !existingIds.contains($0.memberId) }
                    self.members.append(contentsOf: uniqueNewMembers)
                    
                    print("📄 멤버 로드 완료: 총 \(self.members.count)명 / hasNext: \(page.info?.hasNext ?? false)")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Load More (추가 페이지 로드)
    func loadMoreMembersIfNeeded() {
        fetchMembers()
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
                    if var updateMeet = self?.meet {
                        updateMeet.isCreator = false
                        updateMeet.creatorId = memberId
                        NotificationManager.shared.postItem(.updated(updateMeet),
                                                     from: self)
                    }
                    self?.shouldDismiss = true
                }
            )
            .store(in: &cancellables)
    }
}
