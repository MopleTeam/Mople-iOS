//
//  DefaultMentionRepo.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

final class DefaultMentionRepo: BaseRepositories, MentionRepo {
    func execute(meetId: Int, cursor: String?, keyword: String?) async throws -> PageResponse<MemberInfoResponse> {
        return try await networkService.authenticatedRequest {
            try APIEndpoints.fetchMentionList(meetId: meetId,
                                              nextCursor: cursor,
                                              keyword: keyword)
        }
    }
}
