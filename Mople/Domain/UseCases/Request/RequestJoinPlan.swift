//
//  RequestJoinPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

protocol RequestJoinPlan {
    func requestJoinPlan(planId: Int) -> Single<Void>
}
