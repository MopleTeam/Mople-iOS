//
//  CalendarReviewResponse.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

struct CalendarReviewResponse: Decodable {
    let meetId: Int?
    let meetName: String?
    let meetImage: String?
    let reviewId: Int?
    let reviewName: String?
    let reviewTime: String?
    let reviewParticipants: Int?
    let weatherIcon: String?
    let weatherAddress: String?
    let temperature: Double?
    let pop: Double?
}

extension CalendarReviewResponse {
    func toDomain() -> MonthlyPlan {
        return .init(
            id: self.reviewId,
            title: self.reviewName,
            date: DateManager.parseServerFullDate(string: self.reviewTime),
            memberCount: self.reviewParticipants ?? 0,
            meet: .init(id: meetId,
                        name: meetName,
                        imagePath: meetImage),
            weather: .init(address: weatherAddress,
                           imagePath: weatherIcon,
                           temperature: temperature,
                           pop: pop),
            type: .review
        )
    }
}



