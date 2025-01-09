//
//  RequsetParticipationPlan.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol RequsetParticipationPlan {
    func requestParticipationPlan(planId: Int,
                                  isJoining: Bool) -> Single<Void>
}

final class RequsetParticipationPlanUseCase: RequsetParticipationPlan {
    let participationRepo: ParticipationPlanRepo
    
    init(participationRepo: ParticipationPlanRepo) {
        self.participationRepo = participationRepo
    }
    
    func requestParticipationPlan(planId: Int,
                                  isJoining: Bool) -> Single<Void> {
        participationRepo.requestParticipationPlan(planId: planId,
                                                   isJoining: isJoining)
    }
}
