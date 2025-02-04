//
//  CommentCommandRepo.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol CommentCommandRepo {
    func createComment(postId: Int, comment: String) -> Single<[CommentResponse]>
    func deleteComment(commentId: Int) -> Single<Void>
    func editComment(postId: Int,
                     commentId: Int,
                     comment: String) -> Single<[CommentResponse]>
    func reportComment(_ comment: ReportCommentRequest) -> Single<Void>
}
