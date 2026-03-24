//
//  HomeResponse.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

struct HomeDataResponse: Decodable {
    let plans: [PlanResponse]
    let hasJoinedMeet: Bool?
}

extension HomeDataResponse {
    func toDomain() -> HomeData {
        return .init(plans: plans.map({ $0.toDomain() }),
                     hasMeet: hasJoinedMeet ?? true)
        // ⚠️ 향후 서버 작업 완료 시 false로 변경
    }
}
