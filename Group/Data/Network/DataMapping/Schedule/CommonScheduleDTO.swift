//
//  CommonPlanDTO.swift
//  Group
//
//  Created by CatSlave on 11/7/24.
//

import Foundation

#warning("서버와 대조필요")
struct CommonScheduleDTO: Decodable {
    var id: Int?
    var title: String?
    var date: String?
    var address: String?
    var detailAddress: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title = "name"
        case date = "startAt"
        case address
        case detailAddress
    }
}

extension CommonScheduleDTO {
    func toDomain() -> CommonSchedule {

        return .init(id: id,
                     title: title,
                     date: date?.convertDate(),
                     address: address,
                     detailAddress: detailAddress)
    }
}
