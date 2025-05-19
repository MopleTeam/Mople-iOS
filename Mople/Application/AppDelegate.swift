//
//  AppDelegate.swift
//  Group_Project
//
//  Created by CatSlave on 7/11/24.
//

import UIKit
import KakaoSDKCommon
import FirebaseCore
import FirebaseMessaging
import KakaoSDKAuth
import NMapsMap
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private var wasInBackground: Bool = false
    private let appDIContainer = AppDIContainer()
    private var appFlowCoordinator: AppFlowCoordinator?
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        appInitialSetup()
        
        window = UIWindow(frame: UIScreen.main.bounds)

        let navigationController = AppNaviViewController(type: .main)

        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController,
                                                appDIContainer: appDIContainer)
        
        window?.rootViewController = navigationController
        appFlowCoordinator?.start()
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
    
    private func appInitialSetup() {
        configureRealmMigration()
        registerServices()
        remoteNotifications()
        AppAppearance.setupAppearance()
    }
    
    private func remoteNotifications() {
        UNUserNotificationCenter.current().delegate = self
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        appFlowCoordinator?.handleInvite(with: url)
        handleKakaoLogin(with: url)
        return false
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("디바이스 토큰 확인 \(deviceTokenString)")
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        wasInBackground = true
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        guard wasInBackground else { return }
        checkNotifyPermission()
        updateNotifyCount()
    }
}

// MARK: - Service
extension AppDelegate {
    private func registerServices() {
        registerFirebase()
        registerKakaoKey()
        registerNaverMap()
    }
    
    private func registerKakaoKey() {
        let kakaoKey = AppConfiguration.kakaoKey
        KakaoSDK.initSDK(appKey: kakaoKey)
    }
    
    private func registerFirebase() {
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
    }
    
    private func registerNaverMap() {
        let naverId = AppConfiguration.naverID
        NMFAuthManager.shared().clientId = naverId
    }
    
    private func handleKakaoLogin(with url: URL) {
        guard (AuthApi.isKakaoTalkLoginUrl(url)) else { return }
        _ = AuthController.handleOpenUrl(url: url)
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        NotificationManager.shared.post(name: .updateFCMToken)
    }
}

// MARK: - Receive Notification
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        addNotifyCount()
        completionHandler([.sound, .banner, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let url = response.notification.request.content.userInfo
        guard let destination: NotificationDestination = .init(userInfo: url) else {
            return
        }
        appFlowCoordinator?.handleNotificationTap(destination: destination)
    }
}

// MARK: - Notify Handle
extension AppDelegate {
    
    /// badgeCount와 유저 캐시정보 동기화
    private func updateNotifyCount() {
        let badgeCount = UIApplication.shared.applicationIconBadgeNumber
        UserInfoStorage.shared.updateNotifyCount(badgeCount)
    }
    
    private func addNotifyCount() {
        UserInfoStorage.shared.adjustNotifyCount(isIncreasing: true)
    }
    
    /// 백그라운드에서 포그라운드로 진입 시 알림상태가 허용인 경우에만 토큰 업데이트
    private func checkNotifyPermission() {
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { setting in
            guard setting.authorizationStatus == .authorized else { return }
            self.registerForPushNotifications()
        }
    }
    
    /// FCM 토큰 업데이트 요청
    private func registerForPushNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

// MARK: - Realm Migration
extension AppDelegate {
    
    /// Realm 마이그레이션
    func configureRealmMigration() {
        
        let newSchemaVersion: UInt64 = 2
        
        let config = Realm.Configuration(
            schemaVersion: newSchemaVersion,
            migrationBlock: { migration, oldSchemaVersion in
                self.migrateToV2(migration: migration, from: oldSchemaVersion)
            })
        Realm.Configuration.defaultConfiguration = config
        
        _ = try! Realm()
    }
    
    /// Realm 마이그레이션 버전 2
    private func migrateToV2(migration: Migration, from oldSchemaVersion: UInt64) {
        guard oldSchemaVersion < 2 else { return }
        migration.enumerateObjects(ofType: UserInfoEntity.className()) { oldObject, newObject in
            newObject?["notifyCount"] = 0
        }
    }
}


