//
//  DefaultCommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

final class DefaultCommentRepo:BaseRepositories, CommentRepo {
    // MARK: - CRUD
    func createComment(postId: Int,
                       comment: String,
                       mentions: [Int]) -> Single<CommentResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.createComment(postId: postId,
                                           comment: comment,
                                           mentions: mentions)
        }
    }
    
    func fetchCommentList(postId: Int,
                          nextCursor: String?) -> Single<PageResponse<CommentResponse>> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchCommentList(postId: postId,
                                              cursor: nextCursor)
        }
    }
    
    func editComment(commentId: Int,
                     comment: String,
                     mentions: [Int]) -> Single<CommentResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.editComment(commentId: commentId,
                                         comment: comment,
                                         mentions: mentions)
        }
    }
    
    func deleteComment(commentId: Int) -> Single<Void> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.deleteComment(commentId: commentId)
        }
    }
    
    // MARK: - Reply
    func createReplyComment(postId: Int, commentId: Int, comment: String, mentions: [Int]) -> Single<CommentResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.createReplyComment(postId: postId,
                                                commentId: commentId,
                                                comment: comment,
                                                mentions: mentions)
        }
    }
    
    func fetchReplyComment(postId: Int, commentId: Int, nextCursor: String?) -> Single<PageResponse<CommentResponse>> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchReplyCommentList(postId: postId,
                                                   commentId: commentId,
                                                   nextCursor: nextCursor)
        }
    }
    
    // MARK: - Like
    func likeComment(commentId: Int) -> Single<CommentResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.likeComment(commentId: commentId)
        }
    }
}
