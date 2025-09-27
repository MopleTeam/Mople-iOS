//
//  CreateReplyComment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import RxSwift

protocol CreateReplyComment {
    func execute(postId: Int,
                 parentId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment>
}

final class CreateReplyCommentUseCase: CreateReplyComment {
    
    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(postId: Int,
                 parentId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment> {
        return repo
            .createReplyComment(postId: postId,
                                commentId: parentId,
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
