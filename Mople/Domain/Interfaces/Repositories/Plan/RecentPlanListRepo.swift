//
//  RecentPlanList.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import Foundation
import RxSwift

protocol RecentPlanListRepo {
    func fetchRecentPlanList() -> Single<RecentPlanResponse>
}
