//
//  MemberResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct UserInfoDTO: Decodable {
    let userId: Int?
    let nickname: String?
    let image: String?
}

extension UserInfoDTO {
    func toDomain() -> UserInfo {
        return .init(id: userId,
                     name: nickname,
                     imagePath: image)
    }
}
