//
//  DefaultMentionRepo.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

final class DefaultMentionRepo: BaseRepositories, MentionRepo {
    func execute(meetId: Int, cursor: String?, keyword: String?) async throws -> Page<MemberInfo> {
        let response: PageResponse<MemberInfoResponse> = try await networkService.authenticatedRequest {
            try APIEndpoints.fetchMentionList(meetId: meetId,
                                              nextCursor: cursor,
                                              keyword: keyword)
        }
        return Page(totalCount: response.totalCount ?? 0,
                    content: response.content.map { $0.toDomain() },
                    info: response.page?.toDomain())
    }
}
