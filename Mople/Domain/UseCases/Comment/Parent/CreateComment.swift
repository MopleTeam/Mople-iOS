//
//  CreateComment.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol CreateComment {
    func execute(postId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment>
}

final class CreateCommentUseCase: CreateComment {
    
    private let createCommentRepo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.createCommentRepo = repo
    }
    
    func execute(postId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment> {
        return createCommentRepo
            .createComment(postId: postId,
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




    
    
