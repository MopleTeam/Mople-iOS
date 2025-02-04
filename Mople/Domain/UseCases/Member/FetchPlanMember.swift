//
//  PlanMemberList.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

protocol FetchPlanMember {
    func execute(planId: Int) -> Single<PlanMemberList>
}





