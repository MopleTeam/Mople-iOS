//
//  EditComment.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import RxSwift
import Foundation

protocol EditComment {
    func execute(id: Int,
                 text: String,
                 mentions: [Int]) -> Observable<Comment>
}

final class EditCommentUseCase: EditComment {
    
    private let editCommentRepo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.editCommentRepo = repo
    }
    
    func execute(id: Int,
                 text: String,
                 mentions: [Int]) -> Observable<Comment> {
        return editCommentRepo
            .editComment(commentId: id,
                         comment: text,
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
final class MockEditCommentUseCase: EditComment {

    func execute(id: Int,
                 text: String,
                 mentions: [Int]) -> Observable<Comment> {
        print("✅ [Mock] EditComment - id: \(id), text: \(text), mentions: \(mentions)")

        var mockComment = Comment()
        mockComment.isMockup = true
        mockComment.id = id
        mockComment.postId = 1
        mockComment.writerId = 1
        mockComment.writerName = "Mock 사용자"
        mockComment.comment = text
        mockComment.createdDate = Date()
        mockComment.isWriter = true

        return Observable.just(mockComment)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
