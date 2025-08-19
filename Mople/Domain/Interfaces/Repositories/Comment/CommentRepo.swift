//
//  CommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol CommentRepo {
    
    // MARK: - CRUD
    func createComment(postId: Int,
                       comment: String,
                       mentions: [Int]) -> Single<CommentResponse>
    func fetchCommentList(postId: Int,
                          nextCursor: String?) -> Single<PageResponse<CommentResponse>>
    func editComment(commentId: Int,
                     comment: String,
                     mentions: [Int]) -> Single<CommentResponse>
    func deleteComment(commentId: Int) -> Single<Void>
    
    // MARK: - Reply
    func createReplyComment(postId: Int, commentId: Int, comment: String, mentions: [Int]) -> Single<CommentResponse>
    func fetchReplyComment(postId: Int, commentId: Int, nextCursor: String?) -> Single<PageResponse<CommentResponse>>
    
    // MARK: - Like
    func likeComment(commentId:Int) -> Single<CommentResponse>
}
