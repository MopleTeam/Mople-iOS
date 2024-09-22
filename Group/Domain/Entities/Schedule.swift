//
//  Schedule.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation

struct Schedule {
    let id: UUID
    let group: Group
    let title: String
    let place: String
    let participants: [Participant]
    let date: Date
    
    init(id: UUID = UUID(),
         group: Group,
         eventName: String,
         location: String,
         participants: [Participant],
         date: Date) {
        
        self.id = id
        self.group = group
        self.title = eventName
        self.place = location
        self.participants = participants
        self.date = date
    }
    
    var stringDate: String {
        var dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "ko_KR")
            dateFormatter.dateFormat = "YYYY.MM.dd E HH시 mm분"
            
            return dateFormatter
        }()
        
        return dateFormatter.string(from: self.date)
    }
}

struct Group {
    let thumbnailPath: String
    let name: String
    let memberCount: Int
    let lastSchedule: Date
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
