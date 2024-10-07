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
    
    var groupCount: Int = 1
    
    func getEvents() -> [Schedule] {
        var scheduleArray: [Schedule] = []
        
        for i in 0...100 {
            
            let schedule = Schedule(group: getGroup(),
                                    eventName: "모임 \(i)",
                                    location: "장소를 나타냅니다.",
                                    participants: getUser(),
                                    date: Date().addingTimeInterval(3600 * (24 * Double(Int.random(in: 1...500)))),
                                    weather: getWeather())
            
            scheduleArray.append(schedule)
        }
        
        return scheduleArray
    }
    
    func getGroup() -> Group {
        let group: Group = .init(thumbnailPath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300",
              name: "모임 \(groupCount)",
              memberCount: Int.random(in: 1...20),
              lastSchedule: Date())
        
        groupCount += 1
        
        return group
    }

    func getUser() -> [Participant] {
        var members: [Participant] = []
        let num = Int.random(in: 1...10)
        for i in 1...num {
            members.append(.init(name: "User\(i)", imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
        }
        
        return members
    }
    
    func getWeather() -> WeatherInfo {
        return WeatherInfo(imagePath: "https://openweathermap.org/img/wn/0\(Int.random(in: 1...4))d@2x.png",
                           temperature: Int.random(in: 20...30),
                           pop: Bool.random() ? nil : Double.random(in: 0.01 ... 1))
    }
    
    func fetchScheduleList() -> Single<[Schedule]> {
        return Single.just(getEvents())
    }
}
