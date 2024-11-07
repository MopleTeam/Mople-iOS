//
//  SimpleGroupDTO.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct SimpleGroupDTO: Decodable {
    let common: CommonGroupDTO?
    let membersCount: Int?
    let lastScheduleDate: String?
    
    enum CodingKeys: String, CodingKey {
        case members
        case lastScheduleDate = "latestScheduleStartAt"
    }
    
    init(from decoder: Decoder) throws {
        self.common = try? CommonGroupDTO(from: decoder)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.lastScheduleDate = try? container?.decodeIfPresent(String.self, forKey: .lastScheduleDate)
        let memberContainer = try? container?.nestedUnkeyedContainer(forKey: .members)
        self.membersCount = memberContainer?.count
    }
}
