//
//  RequestJoinPlanMock.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

final class RequsetParticipationPlanUseCaseMock: ParticipationPlan {
    func execute(planId: Int, isJoining: Bool) -> Single<Void> {
        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
