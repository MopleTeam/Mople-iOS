//
//  Testtes.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

struct PlanResponse: Decodable {
    let meetId: Int?
    let meetName: String?
    let meetThumnail: String?
    let planId: Int?
    let title: String?
    let date: String?
    let participantCount: Int?
    let isParticipating: Bool?
    let address: String?
    let lat: Double?
    let lot: Double?
    let weatherAddress: String?
    let weatherImagePath: String?
    let temperature: Double?
    let pop: Double?
    

    enum CodingKeys: String, CodingKey {
        case meetId, meetName, planId, address, lat, lot, weatherAddress, pop, temperature
        case meetThumnail = "meetImage"
        case title = "planName"
        case date = "planTime"
        case participantCount = "planMemberCount"
        case isParticipating = "participant"
        case weatherImagePath = "weatherIcon"
    }
}

extension PlanResponse {
    func toDomain() -> Plan {
        let date = DateManager.parseServerDate(string: self.date)
        
        return .init(planId: planId,
                     title: title,
                     date: date,
                     participantCount: participantCount,
                     isParticipating: isParticipating,
                     address: address,
                     meetngSummart: .init(meetId: meetId,
                                          meetName: meetName,
                                          meetThumnail: meetThumnail),
                     location: .init(longitude: lot,
                                     latitude: lat),
                     weather: .init(weatherAddress: weatherAddress,
                                    weatherImagePath: weatherImagePath,
                                    temperature: temperature,
                                    pop: pop))
    }
}
