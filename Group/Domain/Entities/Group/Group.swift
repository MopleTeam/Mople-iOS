//
//  Group.swift
//  Group
//
//  Created by CatSlave on 11/6/24.
//

import Foundation

struct Group: Hashable, Equatable {
    let id: Int?
    let title: String?
    let members: [UserInfo]
    let thumbnailPath: String?
    let createdDate: String?
    let lastSchedule: String?
    
    var memberCountText: String? {
        guard !members.isEmpty else { return "0 명" }
        return "\(members.count)명"
    }
    
    init(id: Int? = nil,
         title: String? = nil,
         members: [UserInfo] = [],
         thumbnailPath: String? = nil,
         createdDate: String? = nil,
         lastSchedule: String? = nil) {
        self.id = id
        self.title = title
        self.members = members
        self.thumbnailPath = thumbnailPath
        self.createdDate = createdDate
        self.lastSchedule = lastSchedule
    }
}
