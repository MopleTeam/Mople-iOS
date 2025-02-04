//
//  MemberInfoRepo.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import RxSwift

protocol MemberInfoRepo {
    func fetchPlanMemberInfo(planId: Int) -> Single<PlanMemberList>
}
