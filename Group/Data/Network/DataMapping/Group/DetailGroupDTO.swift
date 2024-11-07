//
//  GroupResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct DetailGroupDTO: Decodable {
    let common: CommonGroupDTO?
    let creatorId: Int?
    let createdDate: String?
    let members: [UserInfoResponseDTO]?
    
    enum CodingKeys: String, CodingKey {
        case creatorId, members
        case createdDate = "createdAt"
    }
    
    init(from decoder: Decoder) throws {
        self.common = try? CommonGroupDTO(from: decoder)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.creatorId = try? container?.decodeIfPresent(Int.self, forKey: .creatorId)
        self.createdDate = try? container?.decodeIfPresent(String.self, forKey: .createdDate)
        self.members = try? container?.decodeIfPresent([UserInfoResponseDTO].self, forKey: .members)
    }
}


