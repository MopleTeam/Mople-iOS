//
//  DetailPlanDTO.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

struct DetailScheduleDTO: Decodable {
    
    var commonDTO: CommonScheduleDTO?
    var longitude: Double?
    var latitude: Double?
    var participantsDTO: [UserInfoDTO]
    var commentsDTO: [CommentDTO]
    
    enum CodingKeys: String, CodingKey {
        case longitude
        case latitude
        case participants
        case comments = "activeComments"
    }
    
    init(from decoder: Decoder) throws {
        self.commonDTO = try? CommonScheduleDTO(from: decoder)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        
        self.longitude = try? container?.decodeIfPresent(Double.self, forKey: .longitude)
        self.latitude = try? container?.decodeIfPresent(Double.self, forKey: .latitude)
        self.participantsDTO = (try? container?.decodeIfPresent([UserInfoDTO].self, forKey: .participants)) ?? []
        self.commentsDTO = (try? container?.decodeIfPresent([CommentDTO].self, forKey: .comments)) ?? []
    }
}

extension DetailScheduleDTO {
    func toDomain() -> DetailSchedule {
        return .init(commonScheudle: commonDTO?.toDomain(),
                     location: .init(longitude: longitude,
                                     latitude: latitude),
                     participants: participantsDTO.map({ $0.toDomain() }),
                     comments: commentsDTO.map({ $0.toDomain() }))
    }
}


