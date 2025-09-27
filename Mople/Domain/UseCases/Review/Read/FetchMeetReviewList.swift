//
//  FetchMeetPastPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

protocol FetchMeetReviewList {
    func execute(meetId: Int,
                 cursor: String?) -> Observable<Page<Review>>
}

final class FetchMeetReviewListUseCase: FetchMeetReviewList {
    
    private let repo: ReviewRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func execute(meetId: Int,
                 cursor: String?) -> Observable<Page<Review>> {
        return repo.fetchReviewPage(meetId: meetId,
                                    cursor: cursor)
        .map { Page(totalCount: $0.totalCount ?? 0,
                    content: $0.content.map({ $0.toDomain() }),
                    info: $0.page?.toDomain()) }
            .map({
                var page = $0
                self.verifyCreator(with: &page.content)
                return page
            })
            .asObservable()
    }
    
    private func verifyCreator(with planList: inout [Review]) {
        guard let userID else { return }
        planList.enumerated().forEach { index, plan in
            guard let createId = plan.creatorId,
                  userID == createId else { return }
            planList[index].isCreator = true
        }
    }
}
