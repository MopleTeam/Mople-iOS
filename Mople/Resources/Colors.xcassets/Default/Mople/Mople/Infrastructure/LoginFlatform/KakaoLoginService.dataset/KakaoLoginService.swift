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
    func startKakaoLogin() -> Observable<SocialInfo>
}

final class DefaultKakaoLoginService: KakaoLoginService {
    
    init() {
        print(#function, #line, "LifeCycle Test DefaultKakaoLoginService Created" )
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultKakaoLoginService Deinit" )
    }
    
    func startKakaoLogin() -> Observable<SocialInfo> {
        return loginKakao()
            .flatMap { [weak self] idToken -> Observable<SocialInfo> in
                guard let self else { return .empty() }
                
                return parseEmail()
                    .map { email -> SocialInfo in
                        return .init(provider: LoginPlatform.kakao.rawValue,
                                     token: idToken,
                                     email: email)
                    }
            }
    }
    
    private func loginKakao() -> Observable<String> {
        return Observable.create { emitter in
            
            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk { OAuthToken, error in
                    guard let idToken = OAuthToken?.idToken else {
                        emitter.onError(LoginError.kakaoAccountError)
                        return
                    }
                    emitter.onNext(idToken)
                }
            } else {
                UserApi.shared.loginWithKakaoAccount { OAuthToken, error in
                    guard let idToken = OAuthToken?.idToken else {
                        emitter.onError(LoginError.kakaoAccountError)
                        return
                    }
                    emitter.onNext(idToken)
                }
            }
            
            return Disposables.create()
        }
    }
    
    private func parseEmail() -> Observable<String> {
        return Observable.create { emitter in
            UserApi.shared.me() {(user, _) in
                guard let email = user?.kakaoAccount?.email else {
                    emitter.onError(LoginError.kakaoAccountError)
                    return
                }
                emitter.onNext(email)
            }
            return Disposables.create()
        }
        .retry(10)
    }
}
