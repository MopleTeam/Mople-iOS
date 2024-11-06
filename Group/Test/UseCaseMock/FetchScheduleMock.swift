//
//  FetchScheduleMock.swift
//  Group
//
//  Created by CatSlave on 10/7/24.
//

import Foundation
import RxSwift

#warning("향후 메모리 성능을 향상시키기 위해서 페이징 처리를 생각해보면 좋을 것 같음")
final class FetchScheduleMock: FetchSchedule {
    
    private func getEvents() -> [Plan] {
        print(#function, #line)
        var scheduleArray = Plan.getMockEvents()
        
        for _ in 1...100 {
            let randomSchedule = Plan.getRandomSchedule()
            scheduleArray.append(randomSchedule)
        }
        
        return scheduleArray
    }
   
    func fetchScheduleList() -> Single<[Plan]> {
        print(#function, #line)
        
        return Observable.just(getEvents())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .asSingle()
    }
}

