//
//  Testtes.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

#warning("서버랑 맞추기")
struct PlanResponse: Decodable {
    let planId: Int?
    let meetId: Int?
    let meetName: String?
    let meetImage: String?
    let planName: String?
    let planAddress: String?
    let title: String? 
    let creatorId: Int?
    let planTime: String?
    let planMemberCount: Int?
    let lat: Double?
    let lot: Double?
    let weatherAddress: String?
    let weatherIcon: String?
    let temperature: Double?
    let pop: Double?
    let participant: Bool?
}

extension PlanResponse {
    func toDomain() -> Plan {
        let date = DateManager.parseServerFullDate(string: self.planTime)
        
        return .init(id: planId,
                     creatorId: creatorId,
                     title: planName,
                     date: date,
                     participantCount: planMemberCount,
                     isParticipating: participant ?? false,
                     addressTitle: title,
                     address: planAddress,
                     meet: .init(id: meetId,
                                          name: meetName,
                                          imagePath: meetImage),
                     location: .init(longitude: lot,
                                     latitude: lat),
                     weather: .init(address: weatherAddress,
                                    imagePath: weatherIcon,
                                    temperature: temperature,
                                    pop: pop))
    }
}
