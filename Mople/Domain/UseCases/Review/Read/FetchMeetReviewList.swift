//
//  FetchMeetPastPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

protocol FetchMeetReviewList {
    func execute(meetId: Int,
                 cursor: String?) async throws -> Page<Review>
}

final class FetchMeetReviewListUseCase: FetchMeetReviewList {

    private let repo: ReviewRepo
    private let session: UserSessionProvider

    init(repo: ReviewRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    func execute(meetId: Int,
                 cursor: String?) async throws -> Page<Review> {
        let response = try await repo.fetchReviewPage(meetId: meetId,
                                                       cursor: cursor)
        var page = Page(totalCount: response.totalCount ?? 0,
                        content: response.content.map({ $0.toDomain() }),
                        info: response.page?.toDomain())
        verifyCreator(with: &page.content)
        return page
    }

    private func verifyCreator(with planList: inout [Review]) {
        planList.enumerated().forEach { index, plan in
            planList[index].verifyCreator(session.currentUserId)
        }
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchMeetReviewListUseCase: FetchMeetReviewList {

    func execute(meetId: Int, cursor: String?) async throws -> Page<Review> {
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

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return page
    }
}
#endif
