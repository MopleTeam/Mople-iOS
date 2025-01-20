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
    let reviewListRepo: ReviewQueryRepo
    
    init(reviewListRepo: ReviewQueryRepo) {
        self.reviewListRepo = reviewListRepo
    }
    
    func execute(meetId: Int) -> Single<[Review]> {
        return reviewListRepo.fetchReviewList(meetId)
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}
