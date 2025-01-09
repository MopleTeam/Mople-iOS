//
//  ParticipationPlanRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol ParticipationPlanRepo {
    func requestParticipationPlan(planId: Int,
                                  isJoining: Bool) -> Single<Void>
}
