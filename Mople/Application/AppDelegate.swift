//
//  AppDelegate.swift
//  Group_Project
//
//  Created by CatSlave on 7/11/24.
//

import UIKit
import KakaoSDKCommon
import FirebaseCore
import KakaoSDKAuth

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerKakaoKey()
        regiseterFirebase()
        return true
    }
    
    // 알림허용 시 디바이스 토큰 발행 및 apns 서버로 업로드
    // ios 버전 업로드, 앱 업데이트 등 디바이스 토큰 바뀌는 경우
    // 개인 서버 사용 시 : 기존 토큰과 새로운 토큰 비교 후 변경된 경우에만 업로드
    // 파이어베이스 사용 시 : 토큰 발행 시 자동으로 파이어베이스 업로드, 변경또한 동일
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
                
        let deviceTokenString = deviceToken.map { String(format: "%02x", $0) }.joined()
        print("디바이스 토큰 확인")
        print("deviceToken:\(deviceTokenString)")
    }
}

extension AppDelegate {
    private func registerKakaoKey() {
        if let appKey = Bundle.main.object(forInfoDictionaryKey: "KakaoKey") as? String {
            print(#function, #line, "kakaoKey : \(appKey)" )
            KakaoSDK.initSDK(appKey: appKey)
        }
    }
    
    private func regiseterFirebase() {
        FirebaseApp.configure()
    }
}
