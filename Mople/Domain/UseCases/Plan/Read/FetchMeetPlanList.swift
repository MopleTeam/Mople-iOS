//
//  FetchMeetFuturePlanUseCase.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import RxSwift

protocol FetchPlanPage {
    func execute(meetId: Int, cursor: String?) -> Observable<Page<Plan>>
}

final class FetchPlanPageUsecase: FetchPlanPage {
    private let repo: PlanRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: PlanRepo) {
        self.repo = repo
    }
    
    func execute(meetId: Int, cursor: String?) -> Observable<Page<Plan>> {
        return repo.fetchPlanPage(meetId: meetId,
                                  cursor: cursor)
        .asObservable()
        .map { Page(totalCount: $0.totalCount ?? 0,
                    content: $0.content.map({ $0.toDomain() }),
                    info: $0.page?.toDomain()) }
        .map({
            var planPage = $0
            self.verifyCreator(with: &planPage.content)
            return planPage
        })
    }
    
    private func verifyCreator(with planList: inout [Plan]) {
        guard let userID else { return }
        planList.enumerated().forEach { index, plan in
            guard let createId = plan.creatorId,
                  userID == createId else { return }
            planList[index].isCreator = true
        }
    }
}

