//
//  RequsetParticipationPlan.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol RequestParticipationPlan {
    func execute(planId: Int,
                                  isJoining: Bool) -> Single<Void>
}

final class RequestParticipationPlanUseCase: RequestParticipationPlan {
    let participationRepo: PlanCommandRepo
    
    init(participationRepo: PlanCommandRepo) {
        self.participationRepo = participationRepo
    }
    
    func execute(planId: Int,
                 isJoining: Bool) -> Single<Void> {
        participationRepo.requestParticipationPlan(planId: planId,
                                                   isJoining: isJoining)
    }
}
