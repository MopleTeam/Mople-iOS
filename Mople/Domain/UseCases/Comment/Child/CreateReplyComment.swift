//
//  CreateReplyComment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import RxSwift
import Foundation

protocol CreateReplyComment {
    func execute(postId: Int,
                 parentId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment>
}

final class CreateReplyCommentUseCase: CreateReplyComment {
    
    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(postId: Int,
                 parentId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment> {
        return repo
            .createReplyComment(postId: postId,
                                commentId: parentId,
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
final class MockCreateReplyCommentUseCase: CreateReplyComment {

    func execute(postId: Int,
                 parentId: Int,
                 comment: String,
                 mentions: [Int]) -> Observable<Comment> {
        print("✅ [Mock] CreateReplyComment - postId: \(postId), parentId: \(parentId), comment: \(comment)")

        var mockReply = Comment()
        mockReply.isMockup = true
        mockReply.id = Int.random(in: 1000...9999)
        mockReply.postId = postId
        mockReply.parentId = parentId
        mockReply.writerId = 1
        mockReply.writerName = "Mock 사용자"
        mockReply.comment = comment
        mockReply.createdDate = Date()
        mockReply.isWriter = true

        return Observable.just(mockReply)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
