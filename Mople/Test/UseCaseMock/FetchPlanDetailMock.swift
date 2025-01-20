//
//  FetchPlanDetailMOck.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import Foundation
import RxSwift

final class FetchPlanDetailMock: FetchPlanDetail {
    func execute(planId: Int) -> Single<Plan> {
        return Observable.just(Plan.mock(id: planId,
                                         date: Date(),
                                         creatorId: 103))
        .delay(.seconds(2), scheduler: MainScheduler.instance)
        .asSingle()
    }
}
