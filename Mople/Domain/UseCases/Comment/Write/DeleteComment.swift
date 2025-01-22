//
//  DeleteComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol DeleteComment {
    func execute(commentId: Int) -> Single<Void>
}

final class DeleteCommentUseCase: DeleteComment {
    
    private let deleteCommentRepo: CommentCommandRepo
    
    init(deleteCommentRepo: CommentCommandRepo) {
        self.deleteCommentRepo = deleteCommentRepo
    }
    
    func execute(commentId: Int) -> Single<Void> {
        return deleteCommentRepo
            .deleteComment(commentId: commentId)
    }
}
