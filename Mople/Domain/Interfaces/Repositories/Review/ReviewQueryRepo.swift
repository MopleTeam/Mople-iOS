//
//  FetchMeetReviewListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol ReviewQueryRepo {
    func fetchReviewList(_ meetId: Int) -> Single<[ReviewResponse]>
    func fetchReviewDetail(_ reviewId: Int) -> Single<ReviewResponse>
}
