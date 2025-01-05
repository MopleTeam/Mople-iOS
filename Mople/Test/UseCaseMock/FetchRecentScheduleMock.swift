//
//  FetchRecentMeetingMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift



final class FetchRecentScheduleMock: FetchRecentPlan {
    
    func fetchRecentPlan() -> Single<HomeModel> {
        return Single.just(HomeModel.mock())
    }
}

extension HomeModel {
    static func mock() -> Self {
        let plans = Array(1...5).map {
            let date = Date().addingTimeInterval(3600 * (24 * Double($0)))
            return Plan.mock(date: date)
        }

        return .init(plans: plans, hasMeet: Bool.random())
    }
}

extension UserInfo {
    static func getUser() -> [UserInfo] {
        var members: [UserInfo] = []
        let num = Int.random(in: 1...10)
        for i in 1...num {
            members.append(.init(id: nil,
                                 name: "User\(i)",
                                 imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
        }
        
        return members
    }
}
