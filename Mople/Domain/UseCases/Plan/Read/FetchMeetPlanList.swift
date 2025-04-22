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
    private let repo: PlanRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: PlanRepo) {
        self.repo = repo
    }
    
    func execute(meetId: Int) -> Single<[Plan]> {
        return repo.fetchMeetPlanList(meetId)
            .map { $0.map { response in
                response.toDomain() }
            }
            .map { $0.map { [weak self] plan in
                var verifyPlan = plan
                verifyPlan.verifyCreator(self?.userID)
                return verifyPlan }
            }
    }
}
