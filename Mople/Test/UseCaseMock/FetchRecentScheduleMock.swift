//
//  FetchRecentMeetingMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class FetchRecentScheduleMock: FetchHomeData {
    
    func execute() -> Single<HomeData> {
        return  Observable.just(HomeData.mock())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .asSingle()
    }
}




