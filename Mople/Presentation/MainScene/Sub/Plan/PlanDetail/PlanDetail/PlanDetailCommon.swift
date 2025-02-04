//
//  PlanCommonModel.swift
//  Mople
//
//  Created by CatSlave on 1/30/25.
//

import Foundation

enum PlanDetailType {
    case plan
    case review
}

struct CommonPlanModel {
    var id: Int?
    let isCreator: Bool
    let type: PlanDetailType
}

extension CommonPlanModel {
    init(plan: Plan) {
        self.id = plan.id
        self.isCreator = plan.isCreator
        self.type = .plan
    }
    
    init(reveiw: Review) {
        self.id = reveiw.id
        self.isCreator = reveiw.isCreator
        self.type = .review
    }
}
