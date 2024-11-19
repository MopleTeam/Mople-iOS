//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation
import RxSwift

protocol UserLogin {
    func login(_ platform: LoginPlatform) -> Single<Void>
}

enum LoginError: Error {
    case noAuthCode
    case completeError
}

enum LoginPlatform: String {
    case apple = "APPLE"
    case kakao = "KAKAO"
}

final class UserLoginImpl: UserLogin {
    
    let appleLoginService: AppleLoginService
    let kakaoLoginService: KakaoLoginService
    let repository: LoginRepository
    
    init(appleLoginService: AppleLoginService,
         kakaoLoginService: KakaoLoginService,
         userRepository: LoginRepository) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.repository = userRepository
    }
    
    func login(_ platform: LoginPlatform) -> Single<Void> {
        return Observable.just(())
            .delay(.seconds(3), scheduler: MainScheduler.instance)
            .asSingle()
            .flatMap { _ in
                return Single.create { emitter in

                    let loginObserver = self.handleLogin(platform)
                    
                    return loginObserver
        //                .flatMap { self.repository.userLogin(platForm: platform, authCode: $0)}
                        .subscribe(onSuccess: { token in
                            print(#function, #line, "login Teste : \(token)" )
                            emitter(.success(()))
                        }, onFailure: { err in
                            emitter(.failure(err))
                        })
                }
            }
        
    }
    
    private func handleLogin(_ platform: LoginPlatform) -> Single<String> {
        switch platform {
        case .apple:
            appleLoginService.startAppleLogin()
        case .kakao:
            kakaoLoginService.startKakaoLogin()
        }
    }
}
