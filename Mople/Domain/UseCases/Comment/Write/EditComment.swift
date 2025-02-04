//
//  EditComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol EditComment {
    func execute(postId: Int,
                 commentId: Int,
                 comment: String) -> Single<[Comment]>
}

final class EditCommentUseCase: EditComment {
    
    private let editCommentRepo: CommentCommandRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(editCommentRepo: CommentCommandRepo) {
        self.editCommentRepo = editCommentRepo
    }
    
    func execute(postId: Int,
                 commentId: Int,
                 comment: String) -> Single<[Comment]> {
        return editCommentRepo
            .editComment(postId: postId,
                         commentId: commentId,
                         comment: comment)
            .map { $0.map { response in
                response.toDomain() }
            }
            .map { $0.map { [weak self] review in
                var verifyReview = review
                verifyReview.verifyWriter(self?.userId)
                return verifyReview }
            }
    }
}
