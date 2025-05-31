//
//  FetchMeetPastPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

protocol FetchMeetReviewList {
    func execute(meetId: Int) -> Observable<[Review]>
}

final class FetchMeetReviewListUseCase: FetchMeetReviewList {
    
    private let repo: ReviewRepo
    private let userID = UserInfoStorage.shared.userInfo?.id
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func execute(meetId: Int) -> Observable<[Review]> {
        return repo.fetchReviewList(meetId)
            .map { $0.map { response in
                response.toDomain() }
            }
            .map { $0.map { [weak self] review in
                var verifyPlan = review
                verifyPlan.verifyCreator(self?.userID)
                return verifyPlan }
            }
            .asObservable()
    }
}
