//
//  KakaoLoginService.swift
//  Group
//
//  Created by CatSlave on 10/26/24.
//

import Foundation
import RxSwift
import KakaoSDKUser

protocol KakaoLoginService {
    func startKakaoLogin() -> Single<String>
}

final class DefaultKakaoLoginService: KakaoLoginService {
    
    #warning("정리하기")
    func startKakaoLogin() -> Single<String> {
        return Single.create { single in
            guard UserApi.isKakaoTalkLoginAvailable() else { return  Disposables.create() }
            
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                
                guard error == nil else {
                    single(.failure(LoginError.completeError))
                    return
                }
                
                
                UserApi.shared.me() {(user, error) in
                    if let error = error {
                        print(error)
                    }
                    else {
                        if let user = user {
                            let email = user.kakaoAccount?.email
                            print(#function, #line, "login Test : \(email)" )
                        }
                        // 성공 시 동작 구현
                        _ = user
                    }
                }
                
                if let idToken = oauthToken?.idToken {
                    single(.success(idToken))
                } else {
                    single(.failure(LoginError.noAuthCode))
                }
            }
            return Disposables.create()
        }
    }
}
