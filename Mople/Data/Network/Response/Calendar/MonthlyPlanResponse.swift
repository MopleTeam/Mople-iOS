//
//  CalendarDataResponse.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation

struct MonthlyPlanResponse: Decodable {
    let reviews: [CalendarReviewResponse]
    let plans: [CalendarPlanResponse]
}

extension MonthlyPlanResponse {
    func toDomain() -> [MonthlyPlan] {
        let reviewList = reviews.map({ $0.toDomain() })
        let planList = plans.map({ $0.toDomain() })
        return reviewList + planList
    }
}

