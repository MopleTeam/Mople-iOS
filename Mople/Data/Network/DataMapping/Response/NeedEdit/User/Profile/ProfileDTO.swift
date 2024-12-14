//
//  ProfileResponseDTO.swift
//  Group
//
//  Created by CatSlave on 10/16/24.
//

import Foundation

struct ProfileDTO: Decodable {
    var name: String?
    var imagePath: String?
    var badgeCount: Int?
    
    private enum CodingKeys: String, CodingKey {
        case name = "nickName"
        case imagePath = "image"
        case badgeCount
    }
}

extension ProfileDTO {
    func toDomain() -> ProfileInfo {
        return .init(name: name,
                     imagePath: imagePath,
                     badgeCount: badgeCount)
    }
}
