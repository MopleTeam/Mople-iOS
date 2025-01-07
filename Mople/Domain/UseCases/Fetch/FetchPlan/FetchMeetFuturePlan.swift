//
//  FetchMeetFuturePlanUseCase.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import RxSwift

protocol FetchMeetFuturePlan {
    func fetchPlan(meetId: Int) -> Single<[Plan]>
}
