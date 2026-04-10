//
//  DefaultReviewCommnadRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

final class DefaultReviewRepo: BaseRepositories, ReviewRepo {
    func fetchReviewPage(meetId: Int,
                         cursor: String?) async throws -> PageResponse<ReviewResponse> {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchReviewPage(id: meetId, cursor: cursor)
        }
    }

    func fetchReviewDetail(id: Int, isOldPlan: Bool) async throws -> ReviewResponse {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchReviewDetail(id: id, isOldPlan: isOldPlan)
        }
    }

    func deleteReviewImage(reviewId: Int, imageIds: [Int]) async throws {
        try await networkService.authenticatedRequest {
            try APIEndpoints.deleteReviewImage(reviewId: reviewId, imageIds: imageIds)
        }
    }

    func deleteReview(id: Int) async throws {
        try await networkService.authenticatedRequest {
            try APIEndpoints.deleteReview(id: id)
        }
    }
}
