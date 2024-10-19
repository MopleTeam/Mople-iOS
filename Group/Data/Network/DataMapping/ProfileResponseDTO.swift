//
//  ProfileResponseDTO.swift
//  Group
//
//  Created by CatSlave on 10/16/24.
//

import Foundation

struct ProfileResponseDTO: Decodable {
    var name: String?
    var imagePath: String?
    
    private enum CodingKeys: String, CodingKey {
        case name
        case imagePath
    }
}

extension ProfileResponseDTO {
    func toDomain() -> ProfileInfo {
        return .init(name: name,
                     imagePath: imagePath)
    }
}
