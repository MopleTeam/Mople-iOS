//
//  NotificationService.swift
//  Mople
//
//  Created by CatSlave on 1/10/25.
//

import UIKit

protocol NotificationService {
    func requestPremission(completion: (() -> Void)?)
}

final class DefaultNotificationService: NotificationService {
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestPremission(completion: (() -> Void)? = nil) {
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
            if granted == true, err == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            completion?()
        }
    }
}
