//
//  DefaultMeetPlanRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

final class DefaultMeetPlanListRepo: BaseRepositories, MeetPlanListRepo {
    func fetchMeetPlanList(_ meetId: Int) -> RxSwift.Single<[PlanResponse]> {
        return self.networkService.authenticatedRequest {
            try APIEndpoints.fetchMeetPlan(meetId: meetId)
        }
    }
}
