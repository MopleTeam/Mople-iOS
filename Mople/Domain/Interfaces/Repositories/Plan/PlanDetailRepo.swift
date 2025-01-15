//
//  FetchPlanRepo.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//

import RxSwift

protocol PlanDetailRepo {
    func fetchPlanDetail(planId: Int) -> Single<PlanResponse>
}
