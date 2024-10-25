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
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (granted, error) in
            print(#function, #line, "granted : \(granted)" )
            if granted {
                DispatchQueue.main.async {
                    // Apple Push Notification service(APNs)에 등록 요청
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
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
    /*
     Background 일 때 아래의 요청과 같이 표시됨
     "aps":{
         "alert": {
             "title" : "모임관리 어플",
                  "body" : "새로운 약속이 등록되었어요!"
         },
         "sound":"default",
         "badge":5
     }
     */
    
    /*
     Foreground인 경우 아래 설정과 같이 표시됨
     앱에 접속된 상태인데 표시하는 이유
     이벤트 발생 여부 확인
     클릭 시 해당 페이지로 이동
     향후 앱 내의 알림센터에 접속해야만 초기화 시킬 것 (현재는 앱에 접속만 하면 badge 초기화)
    */
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.sound, .banner])
        
        guard let mainNavi =  window?.rootViewController as? UINavigationController,
        let mainTab = mainNavi.viewControllers.filter({ $0 is MainTabBarController }).first as? MainTabBarController else { return }
        
        mainTab.selectedIndex = 2
        
    }
    
    
    /*
     https://ios-development.tistory.com/264
     알림을 클릭해서 Background -> Foregorund 로 넘어온 경우
     해야하는 것
     서버 : badge (미확인 한 알림을 확인하여 앱 아이콘에 표시)
     앱
     - 앱 내에서 알림표시에 숫자 업데이트
     - 알림 클릭 시 앱 아이콘 숫자 초기화, 앱 내 알림 숫자 초기화, 서버로 badge 초기화된 횟수 전송
     */
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification: \(response.notification.request.content)")
            print("Action identifier: \(response.actionIdentifier)")
        
        let url = response.notification.request.content.userInfo
        print(url)

        if let apsArray = url["aps"] as? [String:Any],
           let alert = apsArray["alert"] as? [String:String],
           let body = alert["body"],
           let title = alert["title"] {
            print("\(body)")
            print("\(title.decoded)")
        }
        
        let urlString = url.reduce("Push Url") { partialResult, apsValue in
            partialResult + "\n" + "Key : \(apsValue.key)" + "\n" + "Value : \(apsValue.value)"
        }
    }
}



