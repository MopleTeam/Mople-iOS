//
//  FetchRecentMeetingMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift



final class FetchRecentScheduleMock: FetchRecentPlan {
    
    func fetchRecentPlan() -> Single<HomeModel> {
        return  Observable.just(HomeModel.mock())
            .delay(.milliseconds(3000), scheduler: MainScheduler.instance)
            .asSingle()
    }
}




