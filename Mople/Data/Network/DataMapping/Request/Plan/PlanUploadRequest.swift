//
//  PlanCreate.swift
//  Mople
//
//  Created by CatSlave on 12/10/24.
//

import Foundation

struct PlanUploadRequest: Encodable {
    var meetId: Int?
    var name: String?
    var date: String?
    var location: UploadLocation?
    
    var isValid: Bool {
        guard let _ = meetId,
              let _ = date,
              let _ = location,
              let name = name else { return false }
        return !name.isEmpty
    }
    
    enum CodingKeys: String, CodingKey {
        case meetId, name
        case date = "planTime"
    }
}
