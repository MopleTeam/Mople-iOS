//
//  FetchScheduleList.swift
//  Group
//
//  Created by CatSlave on 10/7/24.
//

import Foundation
import RxSwift

protocol FetchPlanList {
    func fetchPlanList() -> Single<[Plan]>
}

