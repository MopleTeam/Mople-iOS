//
//  MemberInfoRepo.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

protocol MemberRepo {
    func execute(type: MemberListType, nextCursor: String?) async throws -> PageResponse<MemberInfoResponse>
}
