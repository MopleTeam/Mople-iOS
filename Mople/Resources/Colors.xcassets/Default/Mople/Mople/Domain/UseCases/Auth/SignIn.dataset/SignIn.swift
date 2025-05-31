//
//  SignIn.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol SignIn {
    func execute(platform: LoginPlatform) -> Observable<Void>
}

enum LoginError: Error {
    case appleAccountError
    case kakaoAccountError
    case completeError
    case notFoundInfo(result: SocialInfo)
    case cancle
    case handled
    case unknown(Error)
    
    var info: String? {
        switch self {
        case .appleAccountError:
            return L10n.Error.Login.apple
        case .kakaoAccountError:
            return L10n.Error.Login.kakao
        case .completeError:
            return L10n.Error.Login.default
        case .unknown:
            return L10n.Error.default
        case .notFoundInfo, .cancle, .handled:
            return nil
        }
    }
}

enum LoginPlatform: String {
    case apple = "APPLE"
    case kakao = "KAKAO"
}

final class SignInUseCase: SignIn {
    
    private let appleLoginService: AppleLoginService
    private let kakaoLoginService: KakaoLoginService
    private let authenticationRepo: AuthenticationRepo
    
    init(appleLoginService: AppleLoginService,
         kakaoLoginService: KakaoLoginService,
         authenticationRepo: AuthenticationRepo) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.authenticationRepo = authenticationRepo
    }
    
    // MARK: - SignIn
    func execute(platform: LoginPlatform) -> Observable<Void> {
        
        var socialLoginResult: SocialInfo?
        
        return handleLogin(platform)
            .do(onNext: { socialLoginResult = $0 })
            .flatMap({ [weak self] accountInfo -> Single<Void> in
                guard let self else { return .just(()) }
                return self.authenticationRepo
                    .signIn(social: accountInfo)
            })
            .asObservable()
            .catch({ [weak self] err in
                guard let self else { return .error(err) }
                return .error(self.handleError(err, socialLoginResult))
            })
    }
    
    private func handleLogin(_ platform: LoginPlatform) -> Observable<SocialInfo> {
        switch platform {
        case .apple:
            appleLoginService.startAppleLogin()
                .asObservable()
        case .kakao:
            kakaoLoginService.startKakaoLogin()
        }
    }
    
    private func handleError(_ error: Error,
                             _ socialLoginResult: SocialInfo?) -> LoginError {
        switch error {
        case let err as LoginError:
            return err
        case let transferError as DataTransferError:
            return handleTransferError(transferError, socialLoginResult: socialLoginResult)
        default:
            return .unknown(error)
        }
    }
    
    private func handleTransferError(_ error: DataTransferError, socialLoginResult: SocialInfo?) -> LoginError {
        switch error {
        case .noResponse:
            guard let socialLoginResult else { return .completeError }
            return .notFoundInfo(result: socialLoginResult)
        default:
            return .handled
        }
    }
}
