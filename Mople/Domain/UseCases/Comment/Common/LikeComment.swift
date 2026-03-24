//
//  LikeCOmment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import RxSwift
import Foundation

protocol LikeComment {
    func execute(commentId: Int) -> Observable<Comment>
}

final class LikeCommentUseCase: LikeComment {
    
    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(commentId: Int) -> Observable<Comment> {
        return repo.likeComment(commentId: commentId)
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
final class MockLikeCommentUseCase: LikeComment {

    func execute(commentId: Int) -> Observable<Comment> {
        print("✅ [Mock] LikeComment - commentId: \(commentId)")

        var mockComment = Comment()
        mockComment.isMockup = true
        mockComment.id = commentId
        mockComment.postId = 1
        mockComment.writerId = 1
        mockComment.writerName = "Mock 사용자"
        mockComment.comment = "좋아요한 댓글"
        mockComment.createdDate = Date()
        mockComment.isWriter = true
        mockComment.isLiked = true
        mockComment.likeCount = 1

        return Observable.just(mockComment)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
