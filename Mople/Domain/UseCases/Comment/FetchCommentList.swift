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
    
    private let fetchCommentListRepo: CommentQueryRepo
    
    init(fetchCommentListRepo: CommentQueryRepo) {
        self.fetchCommentListRepo = fetchCommentListRepo
    }
    
    func execute(postId: Int) -> Single<[Comment]> {
        fetchCommentListRepo.fetchCommentList(postId: postId)
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}

