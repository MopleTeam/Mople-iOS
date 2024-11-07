//
//  PlanResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct SimpleScheduleDTO: Decodable {
    
    let common: CommonScheduleDTO?
    let groupTitle: String?
    let groupThumbnailPath: String?
    
    enum CodingKeys: String, CodingKey {
        case groupTitle, groupThumbnailPath
    }
    
    init(from decoder: Decoder) throws {
        self.common = try? CommonScheduleDTO(from: decoder)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.groupTitle = try? container?.decodeIfPresent(String.self, forKey: .groupTitle)
        self.groupThumbnailPath = try? container?.decodeIfPresent(String.self, forKey: .groupThumbnailPath)
    }
}

extension SimpleScheduleDTO {
    func toDomain() -> SimpleSchedule {
        return .init(commomScheudle: common?.toDomain(),
                     group: .init(title: groupTitle,
                                  thumbnailPath: groupThumbnailPath))
    }
}


