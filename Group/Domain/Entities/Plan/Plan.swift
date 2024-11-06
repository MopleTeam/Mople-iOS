//
//  Schedule.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation

struct Plan: Hashable, Equatable {
    let id: Int?
    let title: String?
    private let releaseDate: String?
    let group: Group?
    let participants: [UserInfo]
    let location: LocationInfo?
    let weather: WeatherInfo?
    let comments: [Comment]
    
    
    init(id: Int? = nil,
         title: String? = nil,
         releaseDate: String? = nil,
         group: Group? = nil,
         participants: [UserInfo] = [],
         location: LocationInfo? = nil,
         weather: WeatherInfo? = nil,
         comments: [Comment] = []) {
        
        self.id = id
        self.group = group
        self.title = title
        self.location = location
        self.participants = participants
        self.releaseDate = releaseDate
        self.weather = weather
        self.comments = comments
    }
}

extension Plan {
    var date: Date? {
        return releaseDate?.convertDate()
    }
    
    var stringDate: String? {
        guard let date = date else { return nil }
        return DateManager.fullDateTimeFormatter.string(from: date)
    }
}




