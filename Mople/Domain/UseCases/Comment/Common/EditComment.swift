//
//  EditComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol EditComment {
    func execute(id: Int,
                 text: String,
                 mentions: [Int]) -> Observable<Comment>
}

final class EditCommentUseCase: EditComment {
    
    private let editCommentRepo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.editCommentRepo = repo
    }
    
    func execute(id: Int,
                 text: String,
                 mentions: [Int]) -> Observable<Comment> {
        return editCommentRepo
            .editComment(commentId: id,
                         comment: text,
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
