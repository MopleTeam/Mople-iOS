//
//  CommonGroupDTO.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct CommonGroupDTO: Decodable {

    var id: Int?
    var name: String?
    var thumbnailPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case thumbnailPath = "imageUrl"
    }
}

extension CommonGroupDTO {
    func toDomain() -> CommonGroup {
        return .init(id: id,
                     name: name,
                     thumbnailPath: thumbnailPath)
    }
}
