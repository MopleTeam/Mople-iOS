//
//  CommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol CommentRepo {
    func createComment(postId: Int,
                       comment: String,
                       mentions: [Int]) -> Single<CommentResponse>
    func fetchCommentList(postId: Int,
                          nextCursor: String?) -> Single<CommentPageResponse>
    func editComment(commentId: Int,
                     comment: String,
                     mentions: [Int]) -> Single<CommentResponse>
    func deleteComment(commentId: Int) -> Single<Void>
}
