//
//  DeleteComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift

protocol DeleteComment {
    func execute(commentId: Int) -> Observable<Void>
}

final class DeleteCommentUseCase: DeleteComment {
    
    private let deleteCommentRepo: CommentRepo
    
    init(repo: CommentRepo) {
        self.deleteCommentRepo = repo
    }
    
    func execute(commentId: Int) -> Observable<Void> {
        return deleteCommentRepo
            .deleteComment(commentId: commentId)
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockDeleteCommentUseCase: DeleteComment {

    func execute(commentId: Int) -> Observable<Void> {
        print("✅ [Mock] DeleteComment - commentId: \(commentId)")
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
