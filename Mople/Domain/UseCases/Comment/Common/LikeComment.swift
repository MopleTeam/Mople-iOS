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
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(commentId: Int) -> Observable<Comment> {
        return repo.likeComment(commentId: commentId)
            .asObservable()
            .map { $0.toDomain() }
    }
}
