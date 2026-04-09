//
//  CommentManagement.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import RxSwift
import Foundation

protocol FetchCommentList {
    func execute(postId: Int,
                 nextCursor: String?) -> Observable<Page<Comment>>
}

final class FetchCommentListUseCase: FetchCommentList {
    
    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(postId: Int,
                 nextCursor: String?) -> Observable<Page<Comment>> {
        repo.fetchCommentList(postId: postId,
                              nextCursor: nextCursor)
            .asObservable()
            .map { Page(totalCount: $0.totalCount ?? 0,
                        content: $0.content.map({ $0.toDomain() }),
                        info: $0.page?.toDomain()) }
            .map({ self.checkWriter(with: $0)})
    }
    
    private func checkWriter(with list: Page<Comment>) -> Page<Comment> {
        var commentPage = list
        commentPage.content = commentPage.content.map({
            var comment = $0
            comment.verifyWriter(userId)
            return comment
        })
        return commentPage
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockFetchCommentListUseCase: FetchCommentList {

    func execute(postId: Int,
                 nextCursor: String?) -> Observable<Page<Comment>> {
        print("✅ [Mock] FetchCommentList - postId: \(postId), nextCursor: \(nextCursor ?? "nil")")

        let mockComments: [Comment] = (1...5).map { index in
            var comment = Comment()
            comment.isMockup = false
            comment.id = index
            comment.postId = postId
            comment.writerId = index
            comment.writerName = "Mock 사용자 \(index)"
            comment.comment = "Mock 댓글 내용 \(index)"
            comment.createdDate = Date().addingTimeInterval(Double(-index) * 3600)
            comment.isWriter = index == 1
            comment.isLiked = index % 2 == 0
            comment.likeCount = index
            comment.replyCount = index > 3 ? 2 : 0
            return comment
        }

        let page = Page(
            totalCount: mockComments.count,
            content: mockComments,
            info: PageInfo(nextCursor: nil, hasNext: false, size: 20)
        )

        return Observable.just(page)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif

