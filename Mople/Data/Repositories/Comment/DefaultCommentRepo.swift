//
//  DefaultCommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

final class DefaultCommentRepo:BaseRepositories, CommentRepo {
    func createComment(postId: Int,
                       comment: String,
                       mentions: [Int]) -> Single<CommentResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.createComment(id: postId,
                                           comment: comment,
                                           mentions: mentions)
        }
    }
    
    func fetchCommentList(postId: Int,
                          nextCursor: String?) -> Single<CommentPageResponse> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchCommentList(id: postId,
                                              nextCursor: nextCursor)
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
}
