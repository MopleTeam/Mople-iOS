//
//  MentionRepo.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

public protocol MentionRepo {
    func execute(meetId: Int, cursor: String?, keyword: String?) async throws -> Page<MemberInfo>
}
