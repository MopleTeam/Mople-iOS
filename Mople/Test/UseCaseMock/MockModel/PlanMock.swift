//
//  Plan.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

extension Plan {
    static func mock(id: Int, date: Date, posterId: Int) -> Plan {
        .init(id: id,
              title: "개발회의 일정 ID: \(id)",
              date: date,
              participantCount: Int.random(in: 1...10),
              isParticipating: Bool.random(),
              addressTitle: "CGV",
              address: "서울 강남구 선릉로100길 1 서울 강남구 선릉로100길 1 서울 강남구 선릉로100길 1",
              meet: MeetSummary.mock(id: 0),
              location: Location.mock(),
              weather: Weather.mock(),
              postUserId: posterId)
    }
    
    static func recentMock() -> [Plan] {
        let plans = Array(1...5).map {
            let date = Date().addingTimeInterval(3600 * (24 * Double($0)))
            return Plan.mock(id: $0, date: date, posterId: 1)
        }
        
        return plans
    }
    
    static func randomeMock(id: Int) -> Plan {
        let date = Date().addingTimeInterval(3600 * (24 * Double(Int.random(in: 6...100))))
        return Plan.mock(id: id, date: date, posterId: 1)
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
