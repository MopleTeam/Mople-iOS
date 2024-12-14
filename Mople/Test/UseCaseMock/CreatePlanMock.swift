//
//  CreatePlanMock.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation
import RxSwift

final class CreatePlanMock: CreatePlanUsecase {
    func createPlan(with plan: PlanRequest) -> Single<Plan> {
        return Observable.just(())
            .delay(.seconds(2), scheduler: MainScheduler.instance)
            .map { _ -> Plan in
                    .init(planId: 1,
                          title: "개발회의",
                          date: Date(),
                          participantCount: 10,
                          isParticipating: true,
                          address: "서울 강남구 선릉로100길 1",
                          meetngSummart: MeetingSummary.mock(),
                          location: Location.mock(),
                          weather: Weather.mock())
            }
            .asSingle()
    }
}

extension MeetingSummary {
    static func mock() -> MeetingSummary {
        return .init(meetId: 5,
                     meetName: "사이드프로젝트모임",
                     meetThumnail: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300")
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
        return .init(weatherAddress: "서울시 강남구",
                     weatherImagePath: "https://openweathermap.org/img/wn/0\(Int.random(in: 1...4))d@2x.png",
                     temperature: Double.random(in: 0...10),
                     pop: Bool.random() ? nil : Double.random(in: 0.01 ... 1))
    }
}
