//
//  DefaultReviewCommnadRepo.swift
//  Mople
//
//  Created by CatSlave on 2/13/25.
//

import Domain

final class DefaultReviewRepo: BaseRepositories, ReviewRepo {
    func fetchReviewPage(meetId: Int,
                         cursor: String?) async throws -> Page<Review> {
        let response: PageResponse<ReviewResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchReviewPage(id: meetId, cursor: cursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    func fetchReviewDetail(id: Int, isOldPlan: Bool) async throws -> Review {
        let response: ReviewResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchReviewDetail(id: id, isOldPlan: isOldPlan)
        }
        return response.toDomain()
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
