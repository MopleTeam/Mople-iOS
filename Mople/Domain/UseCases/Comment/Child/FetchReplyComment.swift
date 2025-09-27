//
//  FetchReplyComment.swift
//  Mople
//
//  Created by CatSlave on 7/15/25.
//

import RxSwift

protocol FetchReplyCommentList {
    func execute(postId: Int,
                 commentId: Int,
                 nextCursor: String?) -> Observable<Page<Comment>>
}

final class FetchReplyCommentListUseCase: FetchReplyCommentList {
    
    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(postId: Int,
                 commentId: Int,
                 nextCursor: String?) -> Observable<Page<Comment>> {
        repo.fetchReplyComment(postId: postId,
                               commentId: commentId,
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
