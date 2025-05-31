//
//  NotificationDestination.swift
//  Mople
//
//  Created by CatSlave on 4/21/25.
//

import Foundation

enum NotificationDestination {
    case meet(id: Int)
    case plan(id: Int)
    case review(id: Int)
    
    init?(userInfo: [AnyHashable: Any]) {
        if let meetId = Self.parsingId(with: userInfo, key: "meetId") {
            self = .meet(id: meetId)
        } else if let planId = Self.parsingId(with: userInfo, key: "planId") {
            self = .plan(id: planId)
        } else if let reviewId = Self.parsingId(with: userInfo, key: "reviewId") {
            self = .review(id: reviewId)
        } else {
            return nil
        }
    }
    
    private static func parsingId(with userInfo: [AnyHashable: Any], key: String) -> Int? {
        guard let stringValue = userInfo[key] as? String,
              let intValue = Int(stringValue) else { return nil }
        return intValue
    }
}
