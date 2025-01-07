//
//  RequestJoinPlanMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

final class RequestJoinPlanMock: RequestJoinPlan {
    func requestJoinPlan(planId: Int) -> Single<Void> {
        return Observable.just(())
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .asSingle()
    }
}

final class RequestLeavePlanMock: RequestLeavePlan {
    func requstLeavePlan(planId: Int) -> RxSwift.Single<Void> {
        return Observable.just(())
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
