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
                 comment: String) -> Observable<[Comment]>
}

final class EditCommentUseCase: EditComment {
    
    private let editCommentRepo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.editCommentRepo = repo
    }
    
    func execute(postId: Int,
                 commentId: Int,
                 comment: String) -> Observable<[Comment]> {
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
            .asObservable()
    }
}
