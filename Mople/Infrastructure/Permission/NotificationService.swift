//
//  NotificationService.swift
//  Mople
//
//  Created by CatSlave on 1/10/25.
//

import UIKit
import RxSwift

protocol NotificationService {
    func requestPermissions() -> Observable<Bool>
    func checkNotifyPermissions() -> Observable<Bool>
}

final class DefaultNotificationService: NotificationService {

    let notificationCenter = UNUserNotificationCenter.current()
    
    func requestPermissions() -> Observable<Bool> {
        return Observable.create { [weak self] emitter in
            guard let self else { return Disposables.create() }
            
            notificationCenter.getNotificationSettings { [weak self] settings in
                guard let self else {
                    emitter.onCompleted()
                    return
                }
    
                switch settings.authorizationStatus {
                case .notDetermined:
                    requestAuthorization()
                    emitter.onCompleted()
                case .authorized, .provisional:
                    emitter.onNext(true)
                    emitter.onCompleted()
                default:
                    emitter.onCompleted()
                    break
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func requestAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, err in
            guard granted == true, err == nil else { return }
            self?.registerNotifications()
        }
    }
    
    private func registerNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func checkNotifyPermissions() -> Observable<Bool> {
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
