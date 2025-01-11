//
//  FetchPlanDetail.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import RxSwift

protocol FetchPlanDetail {
    func fetchPlanDetail(planId: Int) -> Single<Plan>
}

