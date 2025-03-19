//
//  FetchMeet.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import Foundation
import RxSwift

final class FetchMeetFuturePlanMock: FetchMeetPlanList {
    
    private func getEvents() -> [Plan] {
        print(#function, #line)
        var planArray = Plan.recentMock()
        
        for index in 6...10 {
            let randomPlan = Plan.randomeMock(id: index)
            planArray.append(randomPlan)
        }
        
        planArray.append(Plan.mock(id: 11, date: DateManager.subtractFiveMinutes(Date()), creatorId: 1))
        planArray.append(Plan.mock(id: 12, date: DateManager.addFiveMinutes(Date()), creatorId: 1))
        planArray.append(Plan.mock(id: 13, date: DateManager.getNextMonth(Date()), creatorId: 103))
        return planArray
    }
    
    func execute(meetId: Int) -> Single<[Plan]> {
        return Observable.just(getEvents())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .asSingle()
    }
}
