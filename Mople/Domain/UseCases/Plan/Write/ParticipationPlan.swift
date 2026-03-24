//
//  RequsetParticipationPlan.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol ParticipationPlan {
    func execute(planId: Int,
                 isJoin: Bool) -> Observable<Void>
}

final class ParticipationPlanUseCase: ParticipationPlan {
    let participationRepo: PlanRepo
    
    init(participationRepo: PlanRepo) {
        self.participationRepo = participationRepo
    }
    
    func execute(planId: Int,
                 isJoin: Bool) -> Observable<Void> {
        return participationRepo
            .participationPlan(planId: planId,
                               isJoin: isJoin)
            .asObservable()
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockParticipationPlanUseCase: ParticipationPlan {
    func execute(planId: Int,
                 isJoin: Bool) -> Observable<Void> {
        print("✅ [Mock] 일정 참여 변경 - planId: \(planId), isJoin: \(isJoin)")

        return Observable.just(())
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}
#endif
