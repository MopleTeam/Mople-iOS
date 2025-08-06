//
//  MemberInfoResponse.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

import Foundation

// MARK: - 멤버 데이터 조회 값
struct MembersResponse: Decodable {
    let creatorId: Int
    let members: MemberPageResponse
}

extension MembersResponse {
    func toDomain() -> Members {
        let members = self.members
        return .init(creatorId: creatorId,
                     page: members.toDomain())
    }
}

// MARK: - 페이지 조회 값
struct MemberPageResponse: Decodable {
    let content: [MemberResponse]
    let cursorPage: PageResponse
}

extension MemberPageResponse {
    func toDomain() -> MemberPage {
        let members = content.map { $0.toDomain() }
        let page = cursorPage.toDomain()
        return .init(members: members,
                     page: page)
    }
}

// MARK: - 멤버 조회 값
struct MemberResponse: Decodable {
    let user: MemberInfoResponse
}

extension MemberResponse {
    func toDomain() -> MemberInfo {
        return user.toDomain()
    }
}

struct MemberInfoResponse: Decodable {
    let userId: Int?
    let nickname: String?
    let image: String?
}

extension MemberInfoResponse {
    func toDomain() -> MemberInfo {
        return .init(memberId: userId,
                     nickname: nickname,
                     imagePath: image)
    }
}
