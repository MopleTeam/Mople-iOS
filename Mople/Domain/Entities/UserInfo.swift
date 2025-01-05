//
//  File.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

struct UserInfo: Hashable, Equatable {
    let id: Int?
    let name: String?
    let thumbnailPath: String?
    
    init(id: Int?,
         name: String?,
         imagePath: String?) {
        self.id = id
        self.name = name
        self.thumbnailPath = imagePath
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "userNickname"
        case thumbnailPath = "image_path"
    }
}
