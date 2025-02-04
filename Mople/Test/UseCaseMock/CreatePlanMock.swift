//
//  CreatePlanMock.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation
import RxSwift

final class CreatePlanMock: CreatePlan {
    func execute(with plan: PlanRequest) -> Single<Plan> {
        return Observable.just(())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .map { _ in
                Plan.mock(id: 155, date: Date(), creatorId: 103)
            }
            .asSingle()
    }
}





