//
//  FuturePlanModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

struct MeetPlanViewModel {
    let id: Int?
    let title: String?
    let date: Date?
    let participantCount: Int
    let weather: Weather?
    let postUserID: Int?
    let isParticipant: Bool?
    let isCreator: Bool
    
    var dateString: String? {
        return DateManager.toString(date: date, format: .dot)
    }
    
    var participantCountString: String {
        return L10n.participantCount(participantCount)
    }
}

extension MeetPlanViewModel {
    init(plan: Plan) {
        self.id = plan.id
        self.title = plan.title
        self.date = plan.date
        self.participantCount = plan.participationCount
        self.weather = plan.weather
        self.isParticipant = plan.isParticipation
        self.postUserID = plan.creatorId
        self.isCreator = plan.isCreator
    }
}
