//
//  FetchMeetPastPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

protocol FetchReviewList {
    func fetchReviewList(meetId: Int) -> Single<[Review]>
}

final class fetchReviewListUseCase: FetchReviewList {
    let reviewListRepo: FetchReviewListRepo
    
    init(reviewListRepo: FetchReviewListRepo) {
        self.reviewListRepo = reviewListRepo
    }
    
    func fetchReviewList(meetId: Int) -> Single<[Review]> {
        return reviewListRepo.fetchReviewList(meetId)
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}
