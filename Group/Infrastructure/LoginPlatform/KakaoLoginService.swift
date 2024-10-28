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
    
    func startKakaoLogin() -> Single<String> {
        return Single.create { single in
            guard UserApi.isKakaoTalkLoginAvailable() else { return  Disposables.create() }
            
            UserApi.shared.loginWithKakaoTalk { (oauthToken, error) in
                
                guard error == nil else {
                    single(.failure(LoginError.completeError))
                    return
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
