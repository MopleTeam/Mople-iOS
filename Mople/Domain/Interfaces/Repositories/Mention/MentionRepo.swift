//
//  MentionRepo.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

protocol MentionRepo {
    func execute(meetId: Int, cursor: String?, keyword: String?) async throws -> PageResponse<MemberInfoResponse>
}
