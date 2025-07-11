//
//  CommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol CommentRepo {
    func fetchCommentList(postId: Int,
                          nextCursor: String?) -> Single<CommentPageResponse>
    func createComment(postId: Int, comment: String) -> Single<[CommentPageResponse]>
    func deleteComment(commentId: Int) -> Single<Void>
    func editComment(postId: Int,
                     commentId: Int,
                     comment: String) -> Single<[CommentPageResponse]>
}
