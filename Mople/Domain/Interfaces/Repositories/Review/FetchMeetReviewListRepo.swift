//
//  FetchMeetReviewListRepo.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import RxSwift

protocol FetchMeetReviewListRepo {
    func fetchMeetReviewList(_ meetId: Int) -> Single<[ReviewResponse]>
}
