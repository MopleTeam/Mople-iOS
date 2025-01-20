//
//  FetchCommentListMock.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

final class FetchCommentListMock: FetchCommentList {
    func execute(postId: Int) -> RxSwift.Single<[Comment]> {
        let array = (0...5).map { _ in
            return Comment.mock()
        }
        
        return Observable.just(array)
            .delay(.seconds(5), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
