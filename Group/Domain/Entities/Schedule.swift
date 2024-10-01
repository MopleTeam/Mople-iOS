//
//  Schedule.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation

struct Schedule: Hashable, Equatable {
    let id: UUID?
    let group: Group?
    let title: String?
    let place: String?
    let participants: [Participant]?
    let date: Date
    let weather: WeatherInfo?
    
    init(id: UUID = UUID(),
         group: Group? = nil,
         eventName: String? = nil,
         location: String? = nil,
         participants: [Participant] = [],
         date: Date = Date(),
         weather: WeatherInfo? = nil) {
        
        self.id = id
        self.group = group
        self.title = eventName
        self.place = location
        self.participants = participants
        self.date = date
        self.weather = weather
    }
    
    var stringDate: String? {
        return DateManager.fullDateTimeFormatter.string(from: date)
    }
}

struct Group: Hashable, Equatable {
    let thumbnailPath: String?
    let name: String?
    let memberCount: Int?
    let lastSchedule: Date?
    
    var memberCountString: String? {
        guard let memberCount else { return nil }
        return "\(memberCount)명"
    }
}

struct Participant: Hashable, Equatable {
    let id: UUID?
    let name: String?
    let imagePath: String?
    
    init(id: UUID = UUID(), name: String?, imagePath: String?) {
        self.id = id
        self.name = name
        self.imagePath = imagePath
    }
}

struct WeatherInfo: Hashable, Equatable {
    let imagePath: String?
    let temperature: Int?
}
