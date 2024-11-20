//
//  PlanResponseDTO.swift
//  Group
//
//  Created by CatSlave on 11/5/24.
//

import Foundation

struct SimpleScheduleDTO: Decodable {

    var commonDTO: CommonScheduleDTO?
    var groupId: Int?
    var groupTitle: String?
    var groupThumbnailPath: String?
    var participantsCount: Int?
    #warning("서버에서 보내주는 타입 확인필요")
    var temperature: Int?
    var pop: Double? // Probability of precipitation (강수량)
    var weathreIconPath: String?
    
    
    enum CodingKeys: String, CodingKey {
        case groupId = "meetingId"
        case groupTitle = "meetingName"
        case groupThumbnailPath // 서버 추가확인
        case participants
        case temperature
        case pop // 서버 추가확인
        case weathreIconPath
    }
    
    init(from decoder: Decoder) throws {
        self.commonDTO = try? CommonScheduleDTO(from: decoder)
        
        let container = try? decoder.container(keyedBy: CodingKeys.self)

        self.groupTitle = try? container?.decodeIfPresent(String.self, forKey: .groupTitle)
        self.groupThumbnailPath = try? container?.decodeIfPresent(String.self, forKey: .groupThumbnailPath)
        self.temperature = try? container?.decodeIfPresent(Int.self, forKey: .temperature)
        self.pop = try? container?.decodeIfPresent(Double.self, forKey: .pop)
        self.weathreIconPath = try? container?.decodeIfPresent(String.self, forKey: .weathreIconPath)
        
        let participantsContainer = try? container?.nestedUnkeyedContainer(forKey: .participants)
        self.participantsCount = participantsContainer?.count
    }
}

extension SimpleScheduleDTO {
    func toDomain() -> SimpleSchedule {
        return .init(commonScheudle: commonDTO?.toDomain(),
                     group: .init(id: groupId ,
                                  name: groupTitle ,
                                  thumbnailPath: groupThumbnailPath),
                     participantsCount: participantsCount,
                     weatherInfo: .init(imagePath: weathreIconPath,
                                        temperature: temperature,
                                        pop: pop))
    }
}


