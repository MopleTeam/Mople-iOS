//
//  CommentQeuryRepo.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol CommentQueryRepo {
    func fetchCommentList(postId: Int) -> Single<[CommentResponse]>
}
