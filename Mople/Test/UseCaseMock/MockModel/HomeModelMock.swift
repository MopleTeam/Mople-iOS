//
//  HomeModelMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

extension RecentPlan {
    static func mock() -> Self {
        return .init(plans: Plan.recentMock(), hasMeet: false)
    }
}
