//
//  FetchPlanRepo.swift
//  Mople
//
//  Created by CatSlave on 1/15/25.
//

import RxSwift

protocol PlanQueryRepo {
    func fetchHomeData() -> Single<HomeDataResponse>
    func fetchPlanDetail(planId: Int) -> Single<PlanResponse>
    func fetchMeetPlanList(_ meetId: Int) -> Single<[PlanResponse]>
}
