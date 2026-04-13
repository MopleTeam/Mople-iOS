//
//  DefaultCommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import Domain

final class DefaultCommentRepo: BaseRepositories, CommentRepo {
    // MARK: - CRUD
    func createComment(postId: Int,
                       comment: String,
                       mentions: [Int]) async throws -> Comment {
        let response: CommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.createComment(postId: postId,
                                           comment: comment,
                                           mentions: mentions)
        }
        return response.toDomain()
    }

    func fetchCommentList(postId: Int,
                          nextCursor: String?) async throws -> Page<Comment> {
        let response: PageResponse<CommentResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchCommentList(postId: postId,
                                              cursor: nextCursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    func editComment(commentId: Int,
                     comment: String,
                     mentions: [Int]) async throws -> Comment {
        let response: CommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.editComment(commentId: commentId,
                                         comment: comment,
                                         mentions: mentions)
        }
        return response.toDomain()
    }

    func deleteComment(commentId: Int) async throws {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.deleteComment(commentId: commentId)
        }
    }

    // MARK: - Reply
    func createReplyComment(postId: Int, commentId: Int, comment: String, mentions: [Int]) async throws -> Comment {
        let response: CommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.createReplyComment(postId: postId,
                                                commentId: commentId,
                                                comment: comment,
                                                mentions: mentions)
        }
        return response.toDomain()
    }

    func fetchReplyComment(postId: Int, commentId: Int, nextCursor: String?) async throws -> Page<Comment> {
        let response: PageResponse<CommentResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchReplyCommentList(postId: postId,
                                                   commentId: commentId,
                                                   nextCursor: nextCursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    // MARK: - Like
    func likeComment(commentId: Int) async throws -> Comment {
        let response: CommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.likeComment(commentId: commentId)
        }
        return response.toDomain()
    }
}
