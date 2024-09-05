//
//  FetchRecentMeeting.swift
//  Group
//
//  Created by CatSlave on 8/31/24.

import Foundation
import RxSwift

protocol FetchRecentSchedule {
    func fetchRecent() -> Single<[Schedule]>
}

class fetchRecentScheduleMock: FetchRecentSchedule {
    
    func getEvents() -> [Schedule] {
        return [
            .init(groupName: "모임 1", eventName: "모임 1 일정", location: "서울시 어딘가", participants: getUser(), date: Date()),
            .init(groupName: "모임 2", eventName: "모임 2 일정", location: "성남시 어딘가", participants: getUser(), date: Date()),
            .init(groupName: "모임 3", eventName: "모임 3 일정", location: "구리시 어딘가", participants: getUser(), date: Date()),
            .init(groupName: "모임 4", eventName: "모임 4 일정", location: "구미시 어딘가", participants: getUser(), date: Date()),
            .init(groupName: "모임 5", eventName: "모임 5 일정", location: "제주시 어딘가", participants: getUser(), date: Date())]
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
    
struct Schedule {
    let id: UUID
    let groupName: String?
    let eventName: String?
    let location: String?
    let participants: [Participant]?
    let date: Date?
    
    init(id: UUID = UUID(),
         groupName: String?,
         eventName: String?,
         location: String?,
         participants: [Participant]?,
         date: Date?) {
        
        self.id = id
        self.groupName = groupName
        self.eventName = eventName
        self.location = location
        self.participants = participants
        self.date = date
    }
}

struct Participant {
    let id: UUID?
    let name: String?
    let imagePath: String?
    
    init(id: UUID = UUID(), name: String?, imagePath: String?) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
    }
}


