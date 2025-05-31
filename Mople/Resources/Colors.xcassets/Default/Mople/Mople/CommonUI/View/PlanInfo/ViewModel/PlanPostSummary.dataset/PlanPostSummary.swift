//
//  PlanPostSummary.swift
//  Mople
//
//  Created by CatSlave on 5/11/25.
//

import Foundation

struct PlanPostSummary: PostSummary {
    let isCreator: Bool
    let name: String?
    let particiapantsCount: Int?
    let date: Date?
    let address: String?
    let addressTitle: String?
    let meet: MeetSummary?
    let location: Location
    var isParticipation: Bool
}

extension PlanPostSummary {
    init(plan: Plan) {
        self.isCreator = plan.isCreator
        self.name = plan.title
        self.particiapantsCount = plan.participationCount
        self.date = plan.date
        self.address = plan.address
        self.addressTitle = plan.addressTitle
        self.meet = plan.meet
        self.location = plan.location ?? .defaultLocation
        self.isParticipation = plan.isParticipation
    }
}
