//
//  FetchRecentMeetingMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class fetchRecentScheduleMock: FetchRecentSchedule {
    
    var groupCount: Int = 1
    
    func getEvents() -> [Schedule] {
        var scheduleArray: [Schedule] = []
        
        for i in 0...20 {
            
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
                           temperature: Int.random(in: 20...30))
    }
    
    func fetchRecent() -> Single<[Schedule]> {
        return Single.just(getEvents())
    }
}
