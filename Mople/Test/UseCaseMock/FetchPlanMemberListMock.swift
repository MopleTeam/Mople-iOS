//
//  FetchPlanMemberListMock.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

final class FetchPlanMemberMock: FetchPlanMember {
    func execute(planId: Int) -> Single<PlanMemberList> {
        return Observable.just(PlanMemberList.mock())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
