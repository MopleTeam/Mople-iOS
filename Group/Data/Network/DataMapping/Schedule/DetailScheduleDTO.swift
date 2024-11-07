//
//  DetailPlanDTO.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct DetailScheduleDTO: Decodable {
    
    let common: CommonScheduleDTO?
    var longitude: Double?
    var latitude: Double?
    var comments: [CommentResponseDTO]?
    
    enum CodingKeys: String, CodingKey {
        case longitude
        case latitude
        case comments = "activeComments"
    }
    
    init(from decoder: Decoder) throws {
        self.common = try? CommonScheduleDTO(from: decoder)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.longitude = try? container?.decodeIfPresent(Double.self, forKey: .longitude)
        self.latitude = try? container?.decodeIfPresent(Double.self, forKey: .latitude)
        self.comments = try? container?.decodeIfPresent([CommentResponseDTO].self, forKey: .comments)
    }
}

extension DetailScheduleDTO {
    func toDomain() -> DetailSchedule {
        return .init(commomScheudle: common?.toDomain(),
                     location: .init(longitude: longitude,
                                     latitude: latitude),
                     comments: comments?.map({ $0.toDomain() }) ?? [])
    }
}
