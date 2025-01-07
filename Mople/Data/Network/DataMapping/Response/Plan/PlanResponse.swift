//
//  Testtes.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

#warning("서버랑 맞추기")
struct PlanResponse: Decodable {
    let meetId: Int?
    let meetName: String?
    let meetImage: String?
    let planId: Int?
    let planName: String?
    let planTime: String?
    let planMemberCount: Int?
    let participant: Bool?
    let addressTitle: String? // 서버 이름과 맞춰야 함
    let address: String?
    let lat: Double?
    let lot: Double?
    let weatherAddress: String?
    let weatherIcon: String?
    let temperature: Double?
    let pop: Double?
    
    
    let postUserId: Int?
}

extension PlanResponse {
    func toDomain() -> Plan {
        let date = DateManager.parseServerDate(string: self.planTime)
        
        return .init(id: planId,
                     title: planName,
                     date: date,
                     participantCount: planMemberCount,
                     isParticipating: participant ?? false,
                     addressTitle: addressTitle,
                     address: address,
                     meet: .init(id: meetId,
                                          name: meetName,
                                          imagePath: meetImage),
                     location: .init(longitude: lot,
                                     latitude: lat),
                     weather: .init(address: weatherAddress,
                                    imagePath: weatherIcon,
                                    temperature: temperature,
                                    pop: pop),
                     postUserId: postUserId)
    }
}
