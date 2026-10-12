//
//  PlanPostSummary.swift
//  Mople
//
//  Created by CatSlave on 5/11/25.
//

import Foundation
import Domain

struct PlanPostSummary: PostSummary {
    let postId: Int?
    let isCreator: Bool
    let name: String?
    let particiapantsCount: Int?
    let date: Date?
    let address: String?
    let addressTitle: String?
    let meet: MeetSummary?
    let location: Location?
    var isParticipation: Bool
    var commentCount: Int
    var description: String?
}

extension PlanPostSummary {
    init(plan: Plan) {
        self.postId = plan.id
        self.isCreator = plan.isCreator
        self.name = plan.title
        self.particiapantsCount = plan.participationCount
        self.date = plan.date
        self.address = plan.address
        self.addressTitle = plan.addressTitle
        self.meet = plan.meet
        self.location = plan.location
        self.isParticipation = plan.isParticipation
        self.commentCount = plan.commentCount
        self.description = plan.description
    }
}
