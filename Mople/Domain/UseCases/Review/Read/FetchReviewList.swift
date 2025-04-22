//
//  FetchMeetPastPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

protocol FetchReviewList {
    func execute(meetId: Int) -> Single<[Review]>
}

final class FetchReviewListUseCase: FetchReviewList {
    private let repo: ReviewRepo
    
    init(repo: ReviewRepo) {
        self.repo = repo
    }
    
    func execute(meetId: Int) -> Single<[Review]> {
        return repo.fetchReviewList(meetId)
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}
