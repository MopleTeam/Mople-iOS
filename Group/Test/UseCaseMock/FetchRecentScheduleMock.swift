//
//  FetchRecentMeetingMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class FetchRecentScheduleMock: FetchRecentSchedule {
    
    func fetchRecentSchedule() -> Single<[Plan]> {
        return Single.just(Plan.getMockEvents())
    }
}

extension Plan {
    static func getMockEvents() -> [Self] {
        return [Plan(title: "스벅에서 공부해요!",
                     releaseDate: Date().getIso8601String(),
                     group: Group.getGroup(name: "스터디 모임"),
                     participants: UserInfo.getUser(),
                     location: nil,
                     weather: WeatherInfo.getWeather()),
                Plan(title: "별빛 도서관 독서",
                     releaseDate: Date().addingTimeInterval(3600 * (24 * Double(1))).getIso8601String(),
                     group: Group.getGroup(name: "도서 모임"),
                     participants: UserInfo.getUser(),
                     location: nil,
                     weather: WeatherInfo.getWeather()),
                Plan(title: "롯백 탐사 가요!",
                     releaseDate: Date().addingTimeInterval(3600 * (24 * Double(2))).getIso8601String(),
                     group: Group.getGroup(name: "패션 모임"),
                     participants: UserInfo.getUser(),
                     location: nil,
                     weather: WeatherInfo.getWeather()),
                Plan(title: "인셉션 보러가자!",
                     releaseDate: Date().addingTimeInterval(3600 * (24 * Double(3))).getIso8601String(),
                     group: Group.getGroup(name: "영화 모임"),
                     participants: UserInfo.getUser(),
                     location: nil,
                     weather: WeatherInfo.getWeather()),
                Plan(title: "설악산 가요!",
                     releaseDate: Date().addingTimeInterval(3600 * (24 * Double(4))).getIso8601String(),
                     group: Group.getGroup(name: "산악 모임"),
                     participants: UserInfo.getUser(),
                     location: nil,
                     weather: WeatherInfo.getWeather()),
        ]
    }
    
    static func getRandomSchedule() -> Plan {
        Plan(title: "Random Schedule",
             releaseDate: Date().addingTimeInterval(3600 * (24 * Double(Int.random(in: 6...300)))).getIso8601String(),
             group: Group.getGroup(name: "Random Group"),
             participants: UserInfo.getUser(),
             location: nil,
             weather: WeatherInfo.getWeather())
    }
}

extension Date {
    func getIso8601String() -> String {
        DateManager.isoFormatter.string(from: self)
    }
}

extension Group {
    static func getGroup(name: String) -> Group {
        let group: Group = .init(id: nil,
                                 title: "모임 \(name)",
                                 members: UserInfo.getUser(),
                                 thumbnailPath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300",
                                 createdDate: nil,
                                 lastSchedule: nil)
        
        return group
    }
}

extension UserInfo {
    static func getUser() -> [UserInfo] {
        var members: [UserInfo] = []
        let num = Int.random(in: 1...10)
        for i in 1...num {
            members.append(.init(id: nil,
                                 name: "User\(i)",
                                 imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
        }
        
        return members
    }
}

extension WeatherInfo {
    static func getWeather() -> WeatherInfo {
        return WeatherInfo(imagePath: "https://openweathermap.org/img/wn/0\(Int.random(in: 1...4))d@2x.png",
                           temperature: Int.random(in: 20...30),
                           pop: Bool.random() ? nil : Double.random(in: 0.01 ... 1))
    }
}
