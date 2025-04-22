//
//  CommentManagement.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import RxSwift

protocol FetchCommentList {
    func execute(postId: Int) -> Single<[Comment]>
}

final class FetchCommentListUseCase: FetchCommentList {
    
    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(postId: Int) -> Single<[Comment]> {
        repo.fetchCommentList(postId: postId)
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

