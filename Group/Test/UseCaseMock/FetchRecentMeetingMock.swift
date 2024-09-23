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
        return [
            .init(group: getGroup(), eventName: "모임 1 일정", location: "서울시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 1)), weather: getWeather()),
            .init(group: getGroup(), eventName: "모임 2 일정", location: "성남시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 2)), weather: getWeather()),
            .init(group: getGroup(), eventName: "모임 3 일정", location: "구리시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 3)), weather: getWeather()),
            .init(group: getGroup(), eventName: "모임 4 일정", location: "구미시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 4)), weather: getWeather()),
            .init(group: getGroup(), eventName: "모임 5 일정", location: "제주시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 5)), weather: getWeather())]
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
