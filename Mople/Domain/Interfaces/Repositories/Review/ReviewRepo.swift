//
//  ReviewCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

protocol ReviewRepo {
    func fetchReviewPage(meetId: Int, cursor: String?) async throws -> PageResponse<ReviewResponse>
    func fetchReviewDetail(id: Int, isOldPlan: Bool) async throws -> ReviewResponse
    func deleteReviewImage(reviewId: Int, imageIds: [Int]) async throws
    func deleteReview(id: Int) async throws
}
