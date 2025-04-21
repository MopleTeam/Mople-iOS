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
        if let meetId = userInfo["meetId"] as? Int {
            self = .meet(id: meetId)
        } else if let planId = userInfo["planId"] as? Int {
            self = .plan(id: planId)
        } else if let reviewId = userInfo["reviewId"] as? Int {
            self = .review(id: reviewId)
        } else {
            return nil
        }
    }
}
