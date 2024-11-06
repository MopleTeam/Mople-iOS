//
//  GroupResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct GroupResponseDTO: Decodable {
    var id: Int?
    var name: String?
    var thumbnailPath: String?
    var members: [UserInfoResponseDTO]?
    var createdAt: String?
    var lastPlanDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case thumbnailPath = "imageUrl"
        case members
        case createdAt
        case lastPlanDate = "latestPlanStartAt"
    }
}


