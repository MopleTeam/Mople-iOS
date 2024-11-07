//
//  FetchRecentMeetingMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift



final class FetchRecentScheduleMock: FetchRecentSchedule {
    
    func fetchRecentSchedule() -> Single<[SimpleSchedule]> {
        return Single.just(SimpleSchedule.getMockEvents())
    }
}

extension SimpleSchedule {
    static func getMockEvents() -> [Self] {
        return [SimpleSchedule(commomScheudle: .init(id: nil,
                                                     title: "스벅에서 공부해요!", date: Date(),
                                                     address: "서울 강남구",
                                                     detailAddress: "서울 강남구 강남대로 390 (역삼동)",
                                                     participants: UserInfo.getUser(),
                                                     weather: WeatherInfo.getWeather()),
                               group: .getGroup(name: "스터디 모임")),
                SimpleSchedule(commomScheudle: .init(id: nil,
                                                     title: "스벅에서 공부해요!", date: Date(),
                                                     address: "서울 강남구",
                                                     detailAddress: "서울 강남구 강남대로 390 (역삼동)",
                                                     participants: UserInfo.getUser(),
                                                     weather: WeatherInfo.getWeather()),
                               group: .getGroup(name: "스터디 모임")),
                SimpleSchedule(commomScheudle: .init(id: nil,
                                                     title: "스벅에서 공부해요!", date: Date(),
                                                     address: "서울 강남구",
                                                     detailAddress: "서울 강남구 강남대로 390 (역삼동)",
                                                     participants: UserInfo.getUser(),
                                                     weather: WeatherInfo.getWeather()),
                               group: .getGroup(name: "스터디 모임")),
                SimpleSchedule(commomScheudle: .init(id: nil,
                                                     title: "스벅에서 공부해요!", date: Date(),
                                                     address: "서울 강남구",
                                                     detailAddress: "서울 강남구 강남대로 390 (역삼동)",
                                                     participants: UserInfo.getUser(),
                                                     weather: WeatherInfo.getWeather()),
                               group: .getGroup(name: "스터디 모임")),
                SimpleSchedule(commomScheudle: .init(id: nil,
                                                     title: "스벅에서 공부해요!", date: Date(),
                                                     address: "서울 강남구",
                                                     detailAddress: "서울 강남구 강남대로 390 (역삼동)",
                                                     participants: UserInfo.getUser(),
                                                     weather: WeatherInfo.getWeather()),
                               group: .getGroup(name: "스터디 모임"))
        ]
    }
    
    static func getRandomSchedule() -> SimpleSchedule {
        SimpleSchedule(commomScheudle: .init(id: nil,
                                             title: "Random Schedule",
                                             date: Date().addingTimeInterval(3600 * (24 * Double(Int.random(in: 6...300)))),
                                             address: "Address",
                                             detailAddress: "Detail Address",
                                             participants: UserInfo.getUser(),
                                             weather: WeatherInfo.getWeather()),
                       group: .getGroup(name: "Random Group"))
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
