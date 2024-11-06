//
//  MemberResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct UserInfoResponseDTO: Decodable {
    let id: Int?
    let name: String?
    let thumbnailPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "userNickname"
        case thumbnailPath = "userProfileImgUrl"
    }
}

extension UserInfoResponseDTO {
    func toDomain() -> UserInfo {
        return .init(id: id,
                     name: name,
                     imagePath: thumbnailPath)
    }
}
