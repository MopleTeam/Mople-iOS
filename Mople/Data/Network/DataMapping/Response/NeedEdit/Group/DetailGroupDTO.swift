//
//  GroupResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct DetailGroupDTO: Decodable {
    var commonDTO: CommonGroupDTO?
    var creatorId: Int?
    var createdDate: String?
    var membersDTO: [UserInfoDTO]
    
    enum CodingKeys: String, CodingKey {
        case creatorId, members
        case createdDate = "createdAt"
    }
    
    init(from decoder: Decoder) throws {
        self.commonDTO = try? CommonGroupDTO(from: decoder)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.creatorId = try? container?.decodeIfPresent(Int.self, forKey: .creatorId)
        self.createdDate = try? container?.decodeIfPresent(String.self, forKey: .createdDate)
        self.membersDTO = (try? container?.decodeIfPresent([UserInfoDTO].self, forKey: .members)) ?? []
    }
}



