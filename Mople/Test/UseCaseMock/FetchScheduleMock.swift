//
//  FetchScheduleMock.swift
//  Group
//
//  Created by CatSlave on 10/7/24.
//

import Foundation
import RxSwift

final class FetchScheduleMock: FetchPlanList {
    
    private func getEvents() -> [Plan] {
        print(#function, #line)
        var scheduleArray = Plan.recentMock()
        
        for index in 1...100 {
            let randomSchedule = Plan.randomeMock(id: index)
            scheduleArray.append(randomSchedule)
        }
        
        return scheduleArray
    }
   
    func execute() -> Single<[Plan]> {
        print(#function, #line)
        
        return Observable.just(getEvents())
            .delay(.milliseconds(300), scheduler: MainScheduler.instance)
            .asSingle()
    }
}

