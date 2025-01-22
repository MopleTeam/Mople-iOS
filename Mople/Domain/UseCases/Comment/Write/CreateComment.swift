//
//  CreateComment.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol CreateComment {
    func execute(postId: Int, comment: String) -> Single<[Comment]>
}

final class CreateCommentUseCase: CreateComment {
    
    private let createCommentRepo: CommentCommandRepo
    
    init(createCommentRepo: CommentCommandRepo) {
        self.createCommentRepo = createCommentRepo
    }
    
    func execute(postId: Int,
                 comment: String) -> Single<[Comment]> {
        return createCommentRepo
            .createComment(postId: postId, comment: comment)
            .map { $0.map { reponse in
                reponse.toDomain()}
            }
    }
}




    
    
