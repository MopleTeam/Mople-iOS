//
//  CommonPlanDTO.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

#warning("서버와 대조필요")
struct CommonScheduleDTO: Decodable {
    let id: Int?
    let title: String?
    let date: String?
    let participants: [UserInfoResponseDTO]?
    let address: String?
    let detailAddress: String?
    let temperature: Int?
    let weatherIconPath: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case date = "startAt"
        case participants
        case address
        case detailAddress
        case temperature
        case weatherIconPath = "weatherIconUrl"
    }
}

extension CommonScheduleDTO {
    func toDomain() -> CommonSchedule {

        return .init(id: id,
                     title: title,
                     date: date?.convertDate(),
                     address: address,
                     detailAddress: detailAddress,
                     participants: participants?.map({ $0.toDomain() }) ?? [],
                     weather: .init(imagePath: weatherIconPath,
                                    temperature: temperature))
    }
}
