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
    func startKakaoLogin() -> Single<SocialAccountInfo>
}

final class DefaultKakaoLoginService: KakaoLoginService {
    
    func startKakaoLogin() -> Single<SocialAccountInfo> {
        return Single.zip(loginKakao(), parseEmail())
            .map { idToken, email in
                return .init(platform: LoginPlatform.kakao.rawValue,
                             identityCode: idToken,
                             email: email)
            }
    }
    
    private func loginKakao() -> Single<String> {
        return Single.create { emitter in
            
            guard UserApi.isKakaoTalkLoginAvailable() else {
                emitter(.failure(LoginError.completeError))
                return Disposables.create()
            }
            UserApi.shared.loginWithKakaoTalk { OAuthToken, error in
                guard let idToken = OAuthToken?.idToken else {
                    emitter(.failure(LoginError.completeError))
                    return
                }
                emitter(.success(idToken))
            }
            return Disposables.create()
        }
    }
    
    private func parseEmail() -> Single<String> {
        return Single.create { emitter in
            UserApi.shared.me() {(user, _) in
                guard let email = user?.kakaoAccount?.email else {
                    emitter(.success(""))
                    return
                }
                emitter(.success(email))
            }
            return Disposables.create()
        }
        
    }
}
