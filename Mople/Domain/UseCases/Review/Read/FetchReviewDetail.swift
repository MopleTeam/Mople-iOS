//
//  FetchReviewDetail.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift
import Foundation

protocol FetchReviewDetail {
    func execute(id: Int, isOldPlan: Bool) -> Observable<Review>
}

final class FetchReviewDetailUseCase: FetchReviewDetail {
    
    private let repo: ReviewRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func execute(id: Int, isOldPlan: Bool) -> Observable<Review> {
        return repo.fetchReviewDetail(id: id, isOldPlan: isOldPlan)
            .map { $0.toDomain() }
            .map { [weak self] review in
                var verifyReview = review
                verifyReview.verifyCreator(self?.userID)
                return verifyReview
            }
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchReviewDetailUseCase: FetchReviewDetail {

    func execute(id: Int, isOldPlan: Bool) -> Observable<Review> {
        print("✅ [Mock] FetchReviewDetail - id: \(id), isOldPlan: \(isOldPlan)")

        var mockReview = Review(images: [ReviewImage(id: 1, path: nil),
                                         ReviewImage(id: 2, path: nil)],
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

        return Observable.just(mockReview)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
