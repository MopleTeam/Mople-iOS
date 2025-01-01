//
//  HomeResponse.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

struct HomeResponse: Decodable {
    let plans: [PlanResponse]
    let meetSummarys: [MeetSummaryResponse]

}

extension HomeResponse {
    func toDomain() -> HomeModel {
        return .init(plans: plans.map({ $0.toDomain() }),
                     hasMeet: !meetSummarys.isEmpty)
    }
}
