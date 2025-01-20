//
//  CommentManagement.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import RxSwift

protocol CommentManagement {
    func fetchComments(planId: Int) -> Single<[Comment]>
    func createComment(planId: Int, content: String) -> Single<Void>
}
