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
}

extension CalendarPlanResponse {
    func toDomain() -> MonthlyPlan {
        return .init(
            id: self.planId,
            title: self.planName,
            date: DateManager.parseServerFullDate(string: self.planTime),
            memberCount: self.planParticipants ?? 0,
            meet: .init(id: meetId,
                        name: meetName,
                        imagePath: meetImage),
            weather: .init(address: weatherAddress,
                           imagePath: weatherIcon,
                           temperature: temperature,
                           pop: pop),
            type: .plan
        )
    }
}
