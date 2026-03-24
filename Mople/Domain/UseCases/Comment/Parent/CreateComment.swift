//
//  CreateComment.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift
import Foundation

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

// MARK: - Mock UseCase
#if DEV
final class MockCreateCommentUseCase: CreateComment {

    func execute(postId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment> {
        print("✅ [Mock] CreateComment - postId: \(postId), comment: \(comment), mentions: \(mentions)")

        var mockComment = Comment()
        mockComment.isMockup = true
        mockComment.id = Int.random(in: 1000...9999)
        mockComment.postId = postId
        mockComment.writerId = 1
        mockComment.writerName = "Mock 사용자"
        mockComment.comment = comment
        mockComment.createdDate = Date()
        mockComment.isWriter = true

        return Observable.just(mockComment)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
