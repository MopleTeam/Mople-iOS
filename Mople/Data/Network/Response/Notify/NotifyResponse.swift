//
//  NotifyResponse.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import Foundation

struct NotifyResponse: Decodable {
    let notificationId: Int?
    let meetId: Int?
    let planId: Int?
    let reviewId: Int?
    let payload: NotifyPayloadResponse?
}

extension NotifyResponse {
    func toDomain() -> Notify {
        let notifyType = handleType()
        return .init(id: notificationId,
                     type: notifyType,
                     payload: payload?.toDomain())
    }
    
    private func handleType() -> NotifyType? {
        if let planId {
            return .plan(id: planId)
        } else if let reviewId {
            return .review(id: reviewId)
        } else if let meetId {
            return .meet(id: meetId)
        } else {
            return nil
        }
    }
}












