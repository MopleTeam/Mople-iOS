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
    
    private let createCommentRepo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.createCommentRepo = repo
    }
    
    func execute(postId: Int,
                 comment: String) -> Single<[Comment]> {
        return createCommentRepo
            .createComment(postId: postId, comment: comment)
            .map { $0.map { reponse in
                reponse.toDomain()}
            }
            .map { $0.map { [weak self] review in
                var verifyReview = review
                verifyReview.verifyWriter(self?.userId)
                return verifyReview }
            }
    }
}




    
    
