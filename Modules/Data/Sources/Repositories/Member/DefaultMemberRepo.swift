//
//  DefaultFetchMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

import Domain

public final class DefaultMemberRepo: BaseRepositories, MemberRepo {
    public func execute(type: MemberListType, nextCursor: String?) async throws -> Page<MemberInfo> {
        let response: PageResponse<MemberInfoResponse> = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchMember(type: type, nextCursor: nextCursor)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }
}


