//
//  Review.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import Foundation

struct Review {
    var creatorId: Int?
    var id: Int?
    var name: String?
    var date: Date?
    var participantsCount: Int?
    var address: String?
    var images: [String]
    var meet: MeetSummary?
    var location: Location?
}
