//
//  EditComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol EditComment {
    func execute(commentId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment>
}

final class EditCommentUseCase: EditComment {
    
    private let editCommentRepo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.editCommentRepo = repo
    }
    
    func execute(commentId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment> {
        return editCommentRepo
            .editComment(commentId: commentId,
                         comment: comment,
                         mentions: mentions)
            .asObservable()
            .map { $0.toDomain() }
            .map {
                var comment = $0
                comment.verifyWriter(self.userId)
                return comment
            }
    }
}
