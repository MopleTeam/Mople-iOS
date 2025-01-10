//
//  RequestJoinPlanMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

final class RequsetParticipationPlanUseCaseMock: RequestParticipationPlan {
    func requestParticipationPlan(planId: Int, isJoining: Bool) -> Single<Void> {
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
