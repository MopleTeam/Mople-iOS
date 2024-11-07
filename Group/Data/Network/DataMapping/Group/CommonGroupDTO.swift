//
//  CommonGroupDTO.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct CommonGroupDTO: Decodable {
    let id: Int?
    let name: String?
    let thumbnailPath: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case thumbnailPath = "imageUrl"
    }
}
