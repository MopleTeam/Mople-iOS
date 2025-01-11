//
//  FetchMeetFuturePlanUseCase.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import RxSwift

protocol FetchMeetFuturePlan {
    func fetchPlanList(meetId: Int) -> Single<[Plan]>
}

final class FetchMeetFuturePlanUsecase: FetchMeetFuturePlan {
    let meetPlanRepo: MeetPlanListRepo
    
    init(meetPlanRepo: MeetPlanListRepo) {
        self.meetPlanRepo = meetPlanRepo
    }
    
    func fetchPlanList(meetId: Int) -> Single<[Plan]> {
        return meetPlanRepo.fetchMeetPlanList(meetId)
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}
