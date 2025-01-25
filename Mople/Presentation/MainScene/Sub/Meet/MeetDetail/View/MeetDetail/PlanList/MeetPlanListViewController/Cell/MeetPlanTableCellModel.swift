//
//  FuturePlanModel.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation

struct MeetPlanTableCellModel {
    let id: Int?
    let title: String?
    let date: Date?
    let participantCount: Int?
    let weather: Weather?
    let postUserID: Int?
    let isParticipant: Bool?
    let isCreator: Bool
    
    var dateString: String? {
        return DateManager.toString(date: date, format: .dot)
    }
    
    var participantCountString: String? {
        guard let participantCount = participantCount else { return nil }
        
        return "\(participantCount)명 참여"
    }
}

extension MeetPlanTableCellModel {
    init(plan: Plan) {
        self.id = plan.id
        self.title = plan.title
        self.date = plan.date
        self.participantCount = plan.participantCount
        self.weather = plan.weather
        self.isParticipant = plan.isParticipating
        self.postUserID = plan.creatorId
        self.isCreator = plan.isCreator
    }
}
