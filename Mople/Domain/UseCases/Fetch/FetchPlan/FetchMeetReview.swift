//
//  FetchMeetPastPlan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import RxSwift

protocol FetchMeetReview {
    func fetchReview(meetId: Int) -> Single<[Review]>
}
