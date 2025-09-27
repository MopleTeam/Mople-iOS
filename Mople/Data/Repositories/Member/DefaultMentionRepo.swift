//
//  DefaultMentionRepo.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import RxSwift

final class DefaultMentionRepo: BaseRepositories, MentionRepo {
    func fetchMentionPage(postId: Int, cursor: String?, keyword: String?) -> Single<PageResponse<MemberInfoResponse>> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchMentionPage(postId: postId,
                                              nextCursor: cursor,
                                              keyword: keyword)
        }
    }
}
