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
