//
//  DefaultCommentQueryRepo.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

final class DefaultCommentQueryRepo: BaseRepositories, CommentQueryRepo {
    func fetchCommentList(postId: Int) -> Single<[CommentResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchCommentList(postId: postId)
        }
    }
}
