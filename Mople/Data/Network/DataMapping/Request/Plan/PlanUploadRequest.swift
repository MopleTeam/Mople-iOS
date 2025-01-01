//
//  PlanCreate.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

struct PlanUploadRequest: Encodable {
    var meetId: Int
    var name: String
    var date: String
    var location: UploadPlace
    
    enum CodingKeys: String, CodingKey {
        case meetId, name
        case date = "planTime"
    }
}
