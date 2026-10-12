//
//  MemberInfoRepo.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

public protocol MemberRepo {
    func execute(type: MemberListType, nextCursor: String?) async throws -> Page<MemberInfo>
}
