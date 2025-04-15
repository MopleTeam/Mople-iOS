//
//  NotificationService.swift
//  Mople
//
//  Created by CatSlave on 1/10/25.
//

import UIKit
import RxSwift

protocol NotificationService {
    func requestPermissions(completion: (() -> Void)?)
    func checkPrePermissions() -> Observable<Bool>
}

final class DefaultNotificationService: NotificationService {
    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestPermissions(completion: (() -> Void)? = nil) {
        
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, err in
            if granted == true, err == nil {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
            completion?()
        }
    }
    
    func checkPrePermissions() -> Observable<Bool> {
        return Observable.create { [weak self] emiiter in
            guard let self else { return Disposables.create() }
            notificationCenter.getNotificationSettings {
                let isAllow = $0.authorizationStatus == .authorized
                emiiter.onNext(isAllow)
                emiiter.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
