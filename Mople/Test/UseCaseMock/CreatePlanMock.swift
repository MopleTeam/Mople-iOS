//
//  CreatePlanMock.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation
import RxSwift

final class CreatePlanMock: CreatePlan {
    func createPlan(with plan: PlanUploadRequest) -> Single<Plan> {
        return Observable.just(())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .map { _ in
                Plan.mock(id: 155, date: Date(), posterId: 103)
            }
            .asSingle()
    }
}





