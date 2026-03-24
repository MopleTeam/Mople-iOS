//
//  CalendarPlanResponse.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

struct CalendarPlanResponse: Decodable {
    let meetId: Int?
    let meetName: String?
    let meetImage: String?
    let planId: Int?
    let planName: String?
    let planTime: String?
    let planParticipants: Int?
    let weatherIcon: String?
    let weatherAddress: String?
    let temperature: Double?
    let pop: Double?
    
    var hasLocation: Bool {
        return weatherAddress != nil
    }
}

extension CalendarPlanResponse {
    func toDomain() -> MonthlyPost {
        return .init(
            id: self.planId,
            title: self.planName,
            date: DateManager.parseServerFullDate(string: self.planTime),
            memberCount: self.planParticipants ?? 0,
            meet: .init(id: meetId,
                        name: meetName,
                        imagePath: meetImage),
            weather: hasLocation ? .init(address: weatherAddress,
                                         imagePath: weatherIcon,
                                         temperature: temperature,
                                         pop: pop) : nil,
            type: .plan
        )
    }
}
