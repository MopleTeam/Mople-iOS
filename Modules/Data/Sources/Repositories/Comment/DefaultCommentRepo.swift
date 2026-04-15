//
//  DefaultCommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import Domain

public final class DefaultCommentRepo: BaseRepositories, CommentRepo {
    // MARK: - CRUD
    public func createComment(postId: Int,
                       comment: String,
                       mentions: [Int]) async throws -> Comment {
        let response: CommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.createComment(postId: postId,
                                           comment: comment,
                                           mentions: mentions)
        }
        return response.toDomain()
    }

    public func fetchCommentList(postId: Int,
                          nextCursor: String?) async throws -> Page<Comment> {
        let response: PageResponse<CommentResponse> = try await self.networkService.authenticatedRequest {
            try APIEndpoints.fetchCommentList(postId: postId,
                                              cursor: nextCursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }

    public func editComment(commentId: Int,
                     comment: String,
                     mentions: [Int]) async throws -> Comment {
        let response: CommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.editComment(commentId: commentId,
                                         comment: comment,
                                         mentions: mentions)
        }
        return response.toDomain()
    }

    public func deleteComment(commentId: Int) async throws {
        return try await self.networkService.authenticatedRequest {
            try APIEndpoints.deleteComment(commentId: commentId)
        }
    }

    // MARK: - Reply
    public func createReplyComment(postId: Int, commentId: Int, comment: String, mentions: [Int]) async throws -> Comment {
        let response: CommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.createReplyComment(postId: postId,
                                                commentId: commentId,
                                                comment: comment,
                                                mentions: mentions)
        }
        return response.toDomain()
    }

    public func fetchReplyComment(postId: Int, commentId: Int, nextCursor: String?) async throws -> Page<Comment> {
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
    public func likeComment(commentId: Int) async throws -> Comment {
        let response: CommentResponse = try await self.networkService.authenticatedRequest {
            try APIEndpoints.likeComment(commentId: commentId)
        }
        return response.toDomain()
    }
}
