//
//  SignIn.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol SignIn {
    func execute(platform: LoginPlatform) -> Single<Void>
}

enum LoginError: Error {
    case notFoundInfo(result: SocialInfo)
    case appleAccountError
    case kakaoAccountError
    case completeError
    case appError(error: AppError)
    
    var info: String? {
        switch self {
        case .notFoundInfo:
            return "회원정보를 찾을 수 없습니다."
        case .appleAccountError:
            return "설정에서 Apple 로그인 연동 해제 후\n다시 시도해 주세요."
        case .kakaoAccountError:
            return "카카오 계정과 연동을 실패했습니다.\n다시 시도해 주세요."
        case .completeError:
            return "로그인에 실패했어요.\n다시 시도해 주세요."
        case .appError(let error):
            return error.info
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
        print(#function, #line, "LifeCycle Test SignInUseCase Created" )
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.authenticationRepo = authenticationRepo
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test SignInUseCase Deinit" )
    }
    
    // MARK: - SignIn
    func execute(platform: LoginPlatform) -> Single<Void> {
        
        let loginObserver = self.handleLogin(platform)
        var socialLoginResult: SocialInfo?
        
        return loginObserver
            .do(onSuccess: { socialLoginResult = $0 })
            .flatMap({ [weak self] accountInfo in
                guard let self else { throw AppError.unknown }
                return self.authenticationRepo
                    .signIn(social: accountInfo)
            })
            .catch({ [weak self] err in
                guard let self else { return .error(err) }
                return .error(self.handleError(err, socialLoginResult))
            })
    }
    
    private func handleLogin(_ platform: LoginPlatform) -> Single<SocialInfo> {
        switch platform {
        case .apple:
            appleLoginService.startAppleLogin()
        case .kakao:
            kakaoLoginService.startKakaoLogin()
        }
    }
    
    private func handleError(_ error: Error, _ socialLoginResult: SocialInfo?) -> LoginError {
        switch error {
        case let err as LoginError:
            return err
        case let transferError as DataTransferError:
            return handleTransferError(transferError, socialLoginResult: socialLoginResult)
        default:
            return .appError(error: .unknown)
        }
    }
    
    private func handleTransferError(_ error: DataTransferError, socialLoginResult: SocialInfo?) -> LoginError {
        switch error {
        case .noResponse:
            guard let socialLoginResult else { return .completeError }
            return .notFoundInfo(result: socialLoginResult)
        default:
            return .appError(error: .unknown)
        }
    }
}
