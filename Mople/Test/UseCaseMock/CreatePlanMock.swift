//
//  CreatePlanMock.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation
import RxSwift

final class CreatePlanMock: CreatePlan {
    func createPlan(with plan: PlanUploadRequest) -> Single<Plan> {
        return Observable.just(())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .map { _ in
                Plan.mock(date: Date())
            }
            .asSingle()
    }
}

extension Plan {
    static func mock(date: Date) -> Plan {
        .init(id: 1,
              title: "개발회의",
              date: date,
              participantCount: Int.random(in: 1...10),
              isParticipating: true,
              addressTitle: "CGV",
              address: "서울 강남구 선릉로100길 1",
              meetngSummary: MeetSummary.mock(id: 0),
              location: Location.mock(),
              weather: Weather.mock())
    }
    
    static func recentMock() -> [Plan] {
        let plans = Array(1...5).map {
            let date = Date().addingTimeInterval(3600 * (24 * Double($0)))
            return Plan.mock(date: date)
        }
        
        return plans
    }
    
    static func randomeMock() -> Plan {
        let date = Date().addingTimeInterval(3600 * (24 * Double(Int.random(in: 6...100))))
        return Plan.mock(date: date)
    }
}



extension Location {
    static func mock() -> Location {
        return .init(longitude: 127.04892851392,
                     latitude: 37.5091105328378)
    }
}


extension Weather {
    static func mock() -> Weather {
        return .init(address: "서울시 강남구",
                     imagePath: "https://openweathermap.org/img/wn/0\(Int.random(in: 1...4))d@2x.png",
                     temperature: Double.random(in: 0...10),
                     pop: Bool.random() ? nil : Double.random(in: 0.01 ... 1))
    }
}

extension Date {
    static func random() -> Self {
        return Date().addingTimeInterval(3600 * (24 * Double(Int.random(in: 1...10))))
    }
}
