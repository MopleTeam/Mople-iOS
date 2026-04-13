//
//  ReviewCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

public protocol ReviewRepo {
    func fetchReviewPage(meetId: Int, cursor: String?) async throws -> Page<Review>
    func fetchReviewDetail(id: Int, isOldPlan: Bool) async throws -> Review
    func deleteReviewImage(reviewId: Int, imageIds: [Int]) async throws
    func deleteReview(id: Int) async throws
}
