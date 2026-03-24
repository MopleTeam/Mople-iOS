//
//  FetchMeetPastPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift
import Foundation

protocol FetchMeetReviewList {
    func execute(meetId: Int,
                 cursor: String?) -> Observable<Page<Review>>
}

final class FetchMeetReviewListUseCase: FetchMeetReviewList {
    
    private let repo: ReviewRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func execute(meetId: Int,
                 cursor: String?) -> Observable<Page<Review>> {
        return repo.fetchReviewPage(meetId: meetId,
                                    cursor: cursor)
        .map { Page(totalCount: $0.totalCount ?? 0,
                    content: $0.content.map({ $0.toDomain() }),
                    info: $0.page?.toDomain()) }
            .map({
                var page = $0
                self.verifyCreator(with: &page.content)
                return page
            })
            .asObservable()
    }
    
    private func verifyCreator(with planList: inout [Review]) {
        guard let userID else { return }
        planList.enumerated().forEach { index, plan in
            planList[index].verifyCreator(userID)
        }
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchMeetReviewListUseCase: FetchMeetReviewList {

    func execute(meetId: Int, cursor: String?) -> Observable<Page<Review>> {
        print("✅ [Mock] FetchMeetReviewList - meetId: \(meetId), cursor: \(cursor ?? "nil")")

        let mockReviews: [Review] = (1...3).map { index in
            var review = Review(images: [ReviewImage(id: index, path: nil)],
                                isReviewd: true,
                                description: "Mock 후기 내용 \(index)")
            review.id = index
            review.creatorId = 1
            review.postId = index * 10
            review.name = "Mock 후기 \(index)"
            review.date = Date().addingTimeInterval(Double(-index) * 86400)
            review.participantsCount = index + 2
            review.address = "서울특별시 강남구 역삼동 \(index)번지"
            review.addressTitle = "장소 \(index)"
            review.meet = MeetSummary(id: meetId, name: "Mock 모임", imagePath: nil)
            review.location = Location(longitude: 127.0276, latitude: 37.4979)
            review.isCreator = index == 1
            review.commentCount = index
            return review
        }

        let page = Page(
            totalCount: mockReviews.count,
            content: mockReviews,
            info: PageInfo(nextCursor: nil, hasNext: false, size: 10)
        )

        return Observable.just(page)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
