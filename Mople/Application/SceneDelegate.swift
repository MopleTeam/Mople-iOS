//
//  SceneDelegate.swift
//  Group_Project
//
//  Created by CatSlave on 7/11/24.
//

import UIKit
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    let appDIContainer = AppDIContainer()
    var appFlowCoordinator: AppFlowCoordinator?
    
    var window: UIWindow?
    
    var wasInBackground: Bool = false
    
    // 앱이 실행중이지 않다면(메모리에 없다면)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        reqeustRemoteNotifications()
        AppAppearance.setupAppearance()
        
        let window = UIWindow(windowScene: windowScene)
        let navigationController = UINavigationController()

        appFlowCoordinator = AppFlowCoordinator(navigationController: navigationController,
                                                appDIContainer: appDIContainer)
        
        window.rootViewController = navigationController
        
        appFlowCoordinator?.start()
        
        self.window = window
        self.window?.makeKeyAndVisible()
    }
    
    private func reqeustRemoteNotifications() {
        print(#function, #line)
        UNUserNotificationCenter.current().delegate = self
    }
    
    private func filterUrl(enterType: UIScene.ConnectionOptions) -> String? {
        // Universal Link
        if let userActivity = enterType.userActivities.first,
           userActivity.activityType == NSUserActivityTypeBrowsingWeb,
           let url = userActivity.webpageURL {
            return url.absoluteString
        }
        
        // Url Scheme
        if let url = enterType.urlContexts.first?.url {
            return url.absoluteString
        }
        
        return nil
    }
    
    
    // MARK: - 앱이 메모리에 있을 때
    
    // Url Scheme
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print(#function, #line, "# 29" )
        guard let url = URLContexts.first?.url else { return }
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            _ = AuthController.handleOpenUrl(url: url)
        }
    }
    
    
    
    // Universal Link
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        print("SceneDelegate - continue userActivity")
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb, let url = userActivity.webpageURL else {
            return
        }
    }
    
    // 앱 접속 시 아이콘에 표시된 횟수 초기화
    func sceneDidBecomeActive(_ scene: UIScene) {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        self.wasInBackground = true
        
        
    }

    // Back -> Fore 인 상황
    // Back : 알림 설정을 허용으로 변경
    // Fore : 알림 설정을 확인한 뒤 허용인 경우 디바이스 토큰을 요청
    // wasInBackground : 최초 접속시에도 메서드가 실행되는 것을 방지하기 위해 앱이 back에 존재하는 경우에만 요청
    func sceneWillEnterForeground(_ scene: UIScene) {
        guard wasInBackground else { return }
        
        let center = UNUserNotificationCenter.current()
        
        center.getNotificationSettings { setting in
            guard setting.authorizationStatus == .authorized else { return }
            self.registerForPushNotifications()
        }
    }
    
    func registerForPushNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
}

extension SceneDelegate: UNUserNotificationCenterDelegate {

    /// Foreground(앱 실행)중 알림 수신
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner, .badge])
    }
    
    
    /*
     https://ios-development.tistory.com/264
     알림을 클릭한 경우
     해야하는 것
     서버 : badge (미확인 한 알림을 확인하여 앱 아이콘에 표시)
     앱
     - 앱 내에서 알림표시에 숫자 업데이트
     - 알림 클릭 시 앱 아이콘 숫자 초기화, 앱 내 알림 숫자 초기화, 서버로 badge 초기화된 횟수 전송
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let url = response.notification.request.content.userInfo

//        if let apsArray = url["aps"] as? [String:Any],
//           let alert = apsArray["alert"] as? [String:String],
//           let body = alert["body"],
//           let title = alert["title"] {
//            
//        }
//        
//        let urlString = url.reduce("Push Url") { partialResult, apsValue in
//            partialResult + "\n" + "Key : \(apsValue.key)" + "\n" + "Value : \(apsValue.value)"
//        }
    }
}


