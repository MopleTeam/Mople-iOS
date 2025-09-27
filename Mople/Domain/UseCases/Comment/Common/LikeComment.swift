//
//  LikeCOmment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import RxSwift

protocol LikeComment {
    func execute(commentId: Int) -> Observable<Comment>
}

final class LikeCommentUseCase: LikeComment {
    
    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(commentId: Int) -> Observable<Comment> {
        return repo.likeComment(commentId: commentId)
            .asObservable()
            .map { $0.toDomain() }
            .map {
                var comment = $0
                comment.verifyWriter(self.userId)
                return comment
            }
    }
}
