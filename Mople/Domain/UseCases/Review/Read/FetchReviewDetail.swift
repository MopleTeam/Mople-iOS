//
//  FetchReviewDetail.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

protocol FetchReviewDetail {
    func execute(id: Int, isOldPlan: Bool) async throws -> Review
}

final class FetchReviewDetailUseCase: FetchReviewDetail {

    private let repo: ReviewRepo
    private let session: UserSessionProvider

    init(repo: ReviewRepo, session: UserSessionProvider) {
        self.repo = repo
        self.session = session
    }

    func execute(id: Int, isOldPlan: Bool) async throws -> Review {
        var review = try await repo.fetchReviewDetail(id: id, isOldPlan: isOldPlan)
        review.verifyCreator(self.session.currentUserId)
        return review
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchReviewDetailUseCase: FetchReviewDetail {

    func execute(id: Int, isOldPlan: Bool) async throws -> Review {
        print("✅ [Mock] FetchReviewDetail - id: \(id), isOldPlan: \(isOldPlan)")

        var mockReview = Review(images: [ReviewImage(id: 1, path: "https://harme.s3.ap-northeast-2.amazonaws.com/profile/dbb4032d-5907-4404-971e-6183a7e69242.null"),
                                         ReviewImage(id: 2, path: "https://harme.s3.ap-northeast-2.amazonaws.com/profile/dbb4032d-5907-4404-971e-6183a7e69242.null")],
                                isReviewd: true,
                                description: "Mock 후기 상세 내용입니다.")
        mockReview.id = id
        mockReview.creatorId = 1
        mockReview.postId = 100
        mockReview.name = "Mock 후기"
        mockReview.date = Date()
        mockReview.participantsCount = 5
        mockReview.address = "서울특별시 강남구 테헤란로 123"
        mockReview.addressTitle = "강남역 근처 카페"
        mockReview.meet = MeetSummary(id: 1, name: "Mock 모임", imagePath: nil)
        mockReview.location = Location(longitude: 127.0276, latitude: 37.4979)
        mockReview.isCreator = true
        mockReview.commentCount = 3

        try await Task.sleep(nanoseconds: 1_000_000_000)
        return mockReview
    }
}
#endif
