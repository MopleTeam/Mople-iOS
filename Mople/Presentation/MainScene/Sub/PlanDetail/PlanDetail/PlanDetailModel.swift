//
//  PlanCommonModel.swift
//  Mople
//
//  Created by CatSlave on 1/30/25.
//

import Foundation

enum PlanDetailType {
    case plan
    case review(isReviewed: Bool)
}

struct PlanDetailModel {
    let isCreator: Bool
    let type: PlanDetailType
}

extension PlanDetailModel {
    init(plan: Plan) {
        self.isCreator = plan.isCreator
        self.type = .plan
    }
    
    init(reveiw: Review) {
        self.isCreator = reveiw.isCreator
        self.type = .review(isReviewed: reveiw.isReviewd)
    }
}
