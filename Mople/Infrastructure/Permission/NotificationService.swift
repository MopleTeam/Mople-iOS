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
        
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self else { return }
            switch settings.authorizationStatus {
            case .notDetermined:
                requestAuthorization(completion: completion)
            case .authorized, .provisional:
                registerNotifications()
            default:
                break
            }
        }
    }
    
    private func requestAuthorization(completion: (() -> Void)? = nil) {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, err in
            print(#function, #line, "알림 허용여부 : \(granted)" )
            if granted == true, err == nil {
                self?.registerNotifications()
            } else {
                print(#function, #line, "알림 허용여부\(granted), \(err)" )
            }
            completion?()
        }
    }
    
    private func registerNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func checkPrePermissions() -> Observable<Bool> {
        return Observable.create { [weak self] emitter in
            guard let self else { return Disposables.create() }
            notificationCenter.getNotificationSettings {
                let status = $0.authorizationStatus
                let isAllow = status == .authorized || status == .provisional
                emitter.onNext(isAllow)
                emitter.onCompleted()
            }
            
            return Disposables.create()
        }
    }
}
