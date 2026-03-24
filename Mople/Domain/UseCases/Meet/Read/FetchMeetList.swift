//
//  FetchGroupList.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

protocol FetchMeetPage {
    func execute(cursor: String?) -> Observable<Page<Meet>>
}

final class FetchMeetPageUseCase: FetchMeetPage {
  
    private let repo: MeetRepo
    private let userID = UserInfoStorage.shared.userInfo?.id

    
    init(repo: MeetRepo) {
        self.repo = repo
    }
    
    func execute(cursor: String?) -> Observable<Page<Meet>> {
        return repo.fetchMeetPage(cursor: cursor)
            .map { .init(
                totalCount: $0.totalCount ?? 0,
                content: $0.content
                    .map({
                        var meet = $0.toDomain()
                        self.verifyCreator(with: &meet)
                        return meet
                    }),
                info: $0.page?.toDomain()) }
            .asObservable()
    }
    
    private func verifyCreator(with meet: inout Meet) {
        guard let userID else { return }
        guard let ownerId = meet.creatorId,
              userID == ownerId else { return }
        meet.isCreator = true
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchMeetPageUseCase: FetchMeetPage {

    private let mockMeets: [Meet] = {
        let meetNames = [
            "테니스 동호회", "독서 모임", "등산 클럽", "요가 수업", "게임 모임",
            "사진 동호회", "맛집 탐방", "영화 감상", "음악 감상", "미술 감상",
            "축구 동호회", "배드민턴", "자전거 라이딩", "러닝 크루", "수영 모임",
            "볼링 동호회", "탁구 클럽", "배구 동호회", "농구 동호회", "야구 동호회"
        ]

        let calendar = Calendar.current
        let currentDate = Date()

        return (1...20).map { index in
            Meet(
                isCreator: index % 3 == 0,
                meetSummary: MeetSummary(id: index, name: meetNames[index - 1]),
                sinceDays: index * 5,
                creatorId: index % 3 == 0 ? 1 : 99,
                memberCount: (index % 5) + 2,
                firstPlanDate: index % 2 == 0 ? calendar.date(byAdding: .day, value: index, to: currentDate) : nil
            )
        }
    }()

    func execute(cursor: String?) -> Observable<Page<Meet>> {
        print("✅ [Mock] 모임 목록 조회 - cursor: \(cursor ?? "nil")")

        let startIndex = cursor.flatMap { Int($0) } ?? 0
        let pageSize = 10
        let endIndex = min(startIndex + pageSize, mockMeets.count)

        let contentToReturn = Array(mockMeets[startIndex..<endIndex])
        let hasNext = endIndex < mockMeets.count
        let nextCursor = hasNext ? "\(endIndex)" : nil

        let page = Page(
            totalCount: mockMeets.count,
            content: contentToReturn,
            info: PageInfo(nextCursor: nextCursor, hasNext: hasNext, size: pageSize)
        )

        return Observable.just(page)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

