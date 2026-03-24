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
    let message: String?
    let sendAt: String?
    let planDate: String?
    let isRead: Bool
}

extension NotifyResponse {
    func toDomain() -> Notify {
        let notifyType = handleType()
        let notifyDate = DateManager.parseServerFullDate(string: sendAt)
        
        return .init(id: notificationId,
                     meetImgPath: meetImg,
                     meetTitle: meetName,
                     receiveDate: notifyDate,
                     type: notifyType,
                     message: message,
                     isRead: isRead)
    }
    
    private func handleType() -> NotifyType? {
        let postDate = DateManager.parseServerFullDate(string: planDate)
        if let planId {
            return .plan(id: planId, date: postDate)
        } else if let reviewId {
            return .review(id: reviewId)
        } else if let meetId {
            return .meet(id: meetId)
        } else {
            return nil
        }
    }
}












