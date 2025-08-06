//
//  DefaultMentionRepo.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import RxSwift

final class DefaultMentionRepo: BaseRepositories, MentionRepo {
    func execute(postId: Int, cursor: String?, keyword: String?) -> Single<MemberPageResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchMentionList(postId: postId,
                                              nextCursor: cursor,
                                              keyword: keyword)
        }
    }
}
