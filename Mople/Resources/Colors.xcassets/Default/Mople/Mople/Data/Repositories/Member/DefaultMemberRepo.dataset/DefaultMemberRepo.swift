//
//  DefaultFetchMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

import RxSwift

final class DefaultMemberRepo: BaseRepositories, MemberRepo {
    func execute(type: MemberListType) -> Single<MemberListResponse> {
        return networkService.authenticatedRequest {
            try APIEndpoints.fetchMember(type: type)
        }
    }
}


