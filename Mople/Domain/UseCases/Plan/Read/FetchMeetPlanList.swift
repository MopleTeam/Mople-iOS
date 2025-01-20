//
//  FetchMeetFuturePlanUseCase.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import RxSwift

protocol FetchMeetPlanList {
    func execute(meetId: Int) -> Single<[Plan]>
}

final class FetchMeetPlanListUsecase: FetchMeetPlanList {
    let meetPlanRepo: PlanQueryRepo
    
    init(meetPlanRepo: PlanQueryRepo) {
        self.meetPlanRepo = meetPlanRepo
    }
    
    func execute(meetId: Int) -> Single<[Plan]> {
        return meetPlanRepo.fetchMeetPlanList(meetId)
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}
