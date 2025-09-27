//
//  MemberResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct UserInfoResponse: Decodable {
    let userId: Int?
    let nickname: String?
    let image: String?
    let isExistBadgeCount: Bool?
}

extension UserInfoResponse {
    func toDomain() -> UserInfo {
        return .init(id: userId,
                     hasNotify: isExistBadgeCount ?? false,
                     name: nickname,
                     imagePath: image)
    }
}
