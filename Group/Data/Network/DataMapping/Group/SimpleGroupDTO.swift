//
//  SimpleGroupDTO.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct SimpleGroupDTO: Decodable {

    var commonDTO: CommonGroupDTO?
    var memberCount: Int?
    var lastScheduleDate: String?
    
    enum CodingKeys: String, CodingKey {
        case members
        case lastScheduleDate = "latestScheduleStartAt"
    }
    
    init(from decoder: Decoder) throws {
        self.commonDTO = try? CommonGroupDTO(from: decoder)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.lastScheduleDate = try? container?.decodeIfPresent(String.self, forKey: .lastScheduleDate)
        let memberContainer = try? container?.nestedUnkeyedContainer(forKey: .members)
        self.memberCount = memberContainer?.count
    }
}

extension SimpleGroupDTO {
    func toDomain() -> SimpleGroup {
        return .init(commonGroup: commonDTO?.toDomain(),
                     memberCount: memberCount,
                     lastScheduleDate: lastScheduleDate?.convertDate())
    }
}
