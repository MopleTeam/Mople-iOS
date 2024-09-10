//
//  FetchRecentMeetingMock.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation
import RxSwift

final class fetchRecentScheduleMock: FetchRecentSchedule {
    
    func getEvents() -> [Schedule] {
        return [
            .init(groupName: "모임 1", eventName: "모임 1 일정", location: "서울시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 1))),
            .init(groupName: "모임 2", eventName: "모임 2 일정", location: "성남시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 2))),
            .init(groupName: "모임 3", eventName: "모임 3 일정", location: "구리시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 3))),
            .init(groupName: "모임 4", eventName: "모임 4 일정", location: "구미시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 4))),
            .init(groupName: "모임 5", eventName: "모임 5 일정", location: "제주시 어딘가", participants: getUser(), date: Date().addingTimeInterval(3600 * (24 * 5)))]
    }

    func getUser() -> [Participant] {
        var members: [Participant] = []
        let num = Int.random(in: 1...10)
        for i in 1...num {
            members.append(.init(name: "User\(i)", imagePath: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300"))
        }
        
        return members
    }
    
    func fetchRecent() -> Single<[Schedule]> {
        return Single.just(getEvents())
    }
}
