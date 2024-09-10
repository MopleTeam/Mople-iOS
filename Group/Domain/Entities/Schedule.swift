//
//  Schedule.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import Foundation

struct Schedule {
    let id: UUID
    let groupName: String
    let eventName: String
    let location: String
    let participants: [Participant]
    private let date: Date
    
    init(id: UUID = UUID(),
         groupName: String,
         eventName: String,
         location: String,
         participants: [Participant],
         date: Date) {
        
        self.id = id
        self.groupName = groupName
        self.eventName = eventName
        self.location = location
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
