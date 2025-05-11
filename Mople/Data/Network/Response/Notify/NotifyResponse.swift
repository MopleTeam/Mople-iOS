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
    let meetName: String?
    let meetImg: String?
    let payload: NotifyPayloadResponse?
    let sendAt: String?
}

extension NotifyResponse {
    func toDomain() -> Notify {
        let notifyType = handleType()
        let notifyDate = DateManager.parseServerFullDate(string: sendAt)
        return .init(id: notificationId,
                     meetImgPath: meetImg,
                     meetTitle: meetName,
                     postDate: notifyDate,
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












