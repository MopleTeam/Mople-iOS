//
//  FetchMeetPastPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

protocol FetchMeetReview {
    func fetchReviewList(meetId: Int) -> Single<[Review]>
}

final class fetchMeetReviewUseCase: FetchMeetReview {
    let reviewListRepo: FetchMeetReviewListRepo
    
    init(reviewListRepo: FetchMeetReviewListRepo) {
        self.reviewListRepo = reviewListRepo
    }
    
    func fetchReviewList(meetId: Int) -> Single<[Review]> {
        return reviewListRepo.fetchMeetReviewList(meetId)
            .map { $0.map { response in
                response.toDomain() }
            }
    }
}
