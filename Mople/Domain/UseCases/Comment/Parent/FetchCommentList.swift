//
//  CommentManagement.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import RxSwift

protocol FetchCommentList {
    func execute(postId: Int,
                 nextCursor: String?) -> Observable<CommentPage>
}

final class FetchCommentListUseCase: FetchCommentList {
    
    private let repo: CommentRepo
    private let userId = UserInfoStorage.shared.userInfo?.id
    
    init(repo: CommentRepo) {
        self.repo = repo
    }
    
    func execute(postId: Int,
                 nextCursor: String?) -> Observable<CommentPage> {
        repo.fetchCommentList(postId: postId,
                              nextCursor: nextCursor)
            .asObservable()
            .map { $0.toDomain() }
            .map({ self.checkWriter(with: $0)})
    }
    
    private func checkWriter(with list: CommentPage) -> CommentPage {
        var commentPage = list
        commentPage.content = commentPage.content.map({
            var comment = $0
            comment.verifyWriter(userId)
            return comment
        })
        return commentPage
    }
}

