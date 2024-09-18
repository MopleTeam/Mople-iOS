//
//  AppDelegate.swift
//  Group_Project
//
//  Created by CatSlave on 7/11/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        registerForRemoteNotifications()
        return true
    }
    
    // 서버로 디바이스 토큰을 등록
    // User 프로필에 디바이스 토큰
    // 디바이스 토큰이 바뀔 가능성이 있음
    // 이를 방지하기 위해서 첫 접속시 디바이스 토큰을 같이 받아서 현재와 일치하는 지 확인
    // 일치하지 않는다면 서버로 업데이트
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
                
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("디바이스 토큰 확인")
        print("deviceToken:\(deviceTokenString)")
    }
    
    
    
    private func registerForRemoteNotifications() {                
        let center = UNUserNotificationCenter.current()
        
        center.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        center.requestAuthorization(options: options) { (granted, error) in
            if granted {
                DispatchQueue.main.async {
                    // Apple Push Notification service(APNs)에 등록 요청
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
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
//        completionHandler([.sound, .banner, .badge])
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
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received notification: \(response.notification.request.content)")
            print("Action identifier: \(response.actionIdentifier)")
        
        let url = response.notification.request.content.userInfo
        print(url)

        if let apsArray = url["aps"] as? [String:Any],
           let alert = apsArray["alert"] as? [String:String],
           let body = alert["body"],
           let title = alert["title"] {
            print("\(body.decoded)")
            print("\(title.decoded)")
        }
        
        let urlString = url.reduce("Push Url") { partialResult, apsValue in
            partialResult + "\n" + "Key : \(apsValue.key)" + "\n" + "Value : \(apsValue.value)"
        }
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return true
    }
}

extension Notification.Name {
    static let deviceTokenSaved = Notification.Name("deviceTokenSaved")
    static let urlSaved = Notification.Name("urlSaved")
    
}

struct TestAps: Decodable {
    var alert: Data?

    enum CodingKeys: String, CodingKey {
        case alert
    }
}

struct TestAlert: Decodable {
    var body: String?
    var title: String?
    
    enum CodingKeys: String, CodingKey {
        case body
        case title
    }
}



extension String {
    var decoded: String {
        guard let data = self.data(using: .utf8) else { return self }
        return String(data: data, encoding: .nonLossyASCII) ?? self
    }
}
