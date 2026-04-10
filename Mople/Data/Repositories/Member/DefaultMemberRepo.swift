//
//  DefaultFetchMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

final class DefaultMemberRepo: BaseRepositories, MemberRepo {
    func execute(type: MemberListType, nextCursor: String?) async throws -> PageResponse<MemberInfoResponse> {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchMember(type: type, nextCursor: nextCursor)
        }
    }
}


