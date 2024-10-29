//
//  FetchRecentMeetingMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class FetchRecentScheduleMock: FetchRecentSchedule {
 
    func fetchRecentSchedule() -> Single<[Schedule]> {
        return Single.just(Schedule.getEvents())
    }
}

extension Schedule {
    static func getEvents() -> [Self] {
        return [Schedule(group: getGroup(name: "스터디 모임"),
                         eventName: "스벅에서 공부해요!",
                         location: "장소를 나타냅니다.",
                         participants: getUser(),
                         date: Date(),
                         weather: getWeather()),
                Schedule(group: getGroup(name: "도서 모임"),
                         eventName: "별빛 도서관 독서",
                         location: "장소를 나타냅니다.",
                         participants: getUser(),
                         date: Date().addingTimeInterval(3600 * (24 * Double(1))),
                         weather: getWeather()),
                Schedule(group: getGroup(name: "패션 모임"),
                         eventName: "롯백 탐사 가요!",
                         location: "장소를 나타냅니다.",
                         participants: getUser(),
                         date: Date().addingTimeInterval(3600 * (24 * Double(2))),
                         weather: getWeather()),
                Schedule(group: getGroup(name: "영화 모임"),
                         eventName: "인셉션 보러가자!",
                         location: "장소를 나타냅니다.",
                         participants: getUser(),
                         date: Date().addingTimeInterval(3600 * (24 * Double(3))),
                         weather: getWeather()),
                Schedule(group: getGroup(name: "산악 모임"),
                         eventName: "설악산 가요!",
                         location: "장소를 나타냅니다.",
                         participants: getUser(),
                         date: Date().addingTimeInterval(3600 * (24 * Double(4))),
                         weather: getWeather()),
        ]
    }
    
    static func getRandomSchedule() -> Schedule {
        Schedule(group: getGroup(name: "Random Group"),
                 eventName: "Random Schedule",
                 location: "장소를 나타냅니다.",
                 participants: getUser(),
                 date: Date().addingTimeInterval(3600 * (24 * Double(Int.random(in: 6...300)))),
                 weather: getWeather())
    }
    
    static func getGroup(name: String) -> Group {
        let group: Group = .init(thumbnailPath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300",
              name: "모임 \(name)",
              memberCount: Int.random(in: 1...20),
              lastSchedule: Date())
        
        
        return group
    }

    static func getUser() -> [Participant] {
        var members: [Participant] = []
        let num = Int.random(in: 1...10)
        for i in 1...num {
            members.append(.init(name: "User\(i)", imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
        }
        
        return members
    }
    
    static func getWeather() -> WeatherInfo {
        return WeatherInfo(imagePath: "https://openweathermap.org/img/wn/0\(Int.random(in: 1...4))d@2x.png",
                           temperature: Int.random(in: 20...30),
                           pop: Bool.random() ? nil : Double.random(in: 0.01 ... 1))
    }
}
