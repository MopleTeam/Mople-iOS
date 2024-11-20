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
        return [SimpleSchedule(commonScheudle: .init(id: nil,
                                                     title: "스벅에서 공부해요!",
                                                     date: Date().addingTimeInterval(3600 * (24 * 1)),
                                                     address: "서울 강남구",
                                                     detailAddress: "서울 강남구 강남대로 390 (역삼동)"),
                               group: .getGroup(name: "스터디 모임"),
                               participantsCount: Int.random(in: 5...50),
                               weatherInfo: .getWeather()),
                SimpleSchedule(commonScheudle: .init(id: nil,
                                                     title: "다산성곽 도서관 독서",
                                                     date: Date().addingTimeInterval(3600 * (24 * 2)),
                                                     address: "서울 중구",
                                                     detailAddress: "서울특별시 중구 동호로17길 173"),
                               group: .getGroup(name: "도서 모임"),
                               participantsCount: Int.random(in: 5...50),
                               weatherInfo: .getWeather()),
                SimpleSchedule(commonScheudle: .init(id: nil,
                                                     title: "롯백 탐사 하실 분!",
                                                     date: Date().addingTimeInterval(3600 * (24 * 3)),
                                                     address: "서울 송파구",
                                                     detailAddress: "서울 송파구 올림픽로 240 롯데백화점 잠실점"),
                               group: .getGroup(name: "패션 모임"),
                               participantsCount: Int.random(in: 5...50),
                               weatherInfo: .getWeather()),
                SimpleSchedule(commonScheudle: .init(id: nil,
                                                     title: "인셉션 재개봉 다시 보실 분!",
                                                     date: Date().addingTimeInterval(3600 * (24 * 4)),
                                                     address: "서울 강남구",
                                                     detailAddress: "서울특별시 강남구 강남대로 438 (역삼동, 스타플렉스)"),
                               group: .getGroup(name: "영화 모임"),
                               participantsCount: Int.random(in: 5...50),
                               weatherInfo: .getWeather()),
                SimpleSchedule(commonScheudle: .init(id: nil,
                                                     title: "설악산 가요!",
                                                     date: Date().addingTimeInterval(3600 * (24 * 5)),
                                                     address: "강원도 양야군",
                                                     detailAddress: "강원 양양군 대청봉길 1"),
                               group: .getGroup(name: "등산 모임"),
                               participantsCount: Int.random(in: 5...50),
                               weatherInfo: .getWeather())
                
                
        ]
    }
    
    static func getRandomSchedule() -> SimpleSchedule {
        SimpleSchedule(commonScheudle: .init(id: nil,
                                             title: "Random Schedule",
                                             date: Date().addingTimeInterval(3600 * (24 * Double(Int.random(in: 6...1000)))),
                                             address: "Address",
                                             detailAddress: "Detail Address"),
                       group: .getGroup(name: "Random Group"),
                       participantsCount: Int.random(in: 5...50),
                       weatherInfo: .getWeather())
    }
}

extension CommonGroup {
    static func getGroup(name: String) -> CommonGroup {
        return .init(id: 1,
                     name: "모임 \(name)",
                     thumbnailPath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300")
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
