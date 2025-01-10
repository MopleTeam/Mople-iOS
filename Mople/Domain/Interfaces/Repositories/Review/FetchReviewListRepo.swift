//
//  FetchMeetReviewListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol FetchReviewListRepo {
    func fetchReviewList(_ meetId: Int) -> Single<[ReviewResponse]>
}
