//
//  HomeResponse.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

struct HomeDataResponse: Decodable {
    let plans: [PlanResponse]
    let meets: [MeetSummaryResponse]

}

extension HomeDataResponse {
    func toDomain() -> HomeData {
        return .init(plans: plans.map({ $0.toDomain() }),
                     meets: meets.map({ $0.toDomain() }))
    }
}
