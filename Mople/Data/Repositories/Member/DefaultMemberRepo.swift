//
//  DefaultFetchMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

import RxSwift

final class DefaultMemberRepo: BaseRepositories, MemberRepo {
    func execute(type: MemberListType, nextCursor: String?) -> Single<MembersResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchMember(type: type, nextCursor: nextCursor)
        }
    }
}


