//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import Foundation
import RxSwift

protocol SignIn {
    func login(_ platform: LoginPlatform) -> Single<Void>
}

enum AppError: Error {
    case networkError
    case unknownError
    
    var info: String {
        switch self {
        case .networkError:
            "네트워크 연결을 확인해주세요."
        case .unknownError:
            "오류가 발생했습니다. \n잠시 후 다시 시도해주세요."
        }
    }
}

enum LoginError: Error {
    case notFoundInfo(result: SocialAccountInfo)
    case noAccount
    case completeError
    case appError(error: AppError)
    
    var info: String? {
        switch self {
        case .notFoundInfo(let message):
            return "회원정보를 찾을 수 없습니다."
        case .noAccount:
            return "설정에서 Apple 로그인 연동 해제 후\n다시 시도해 주세요."
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
    
    let appleLoginService: AppleLoginService
    let kakaoLoginService: KakaoLoginService
    let signInRepo: SignInRepo
    
    init(appleLoginService: AppleLoginService,
         kakaoLoginService: KakaoLoginService,
         signInRepo: SignInRepo) {
        self.appleLoginService = appleLoginService
        self.kakaoLoginService = kakaoLoginService
        self.signInRepo = signInRepo
    }
    
    func login(_ platform: LoginPlatform) -> Single<Void> {
        
        let loginObserver = self.handleLogin(platform)
        var socialLoginResult: SocialAccountInfo?
        
        return loginObserver
            .do(onSuccess: { socialLoginResult = $0 })
            .flatMap({ self.signInRepo.signIn(socialAccountInfo: $0) })
            .observe(on: MainScheduler.instance)
            .catch({ .error(self.handleError($0, socialLoginResult)) })
    }
    
    private func handleLogin(_ platform: LoginPlatform) -> Single<SocialAccountInfo> {
        switch platform {
        case .apple:
            appleLoginService.startAppleLogin()
        case .kakao:
            kakaoLoginService.startKakaoLogin()
        }
    }
    
    private func handleError(_ error: Error, _ socialLoginResult: SocialAccountInfo?) -> LoginError {
        switch error {
        case let err as LoginError:
            return err
        case let transferError as DataTransferError:
            return handleTransferError(transferError, socialLoginResult: socialLoginResult)
        default:
            return .appError(error: .unknownError)
        }
    }
    
    private func handleTransferError(_ error: DataTransferError, socialLoginResult: SocialAccountInfo?) -> LoginError {
        switch error {
        case .httpRespon(let statusCode, _):
            switch statusCode {
            case 404:
                if let socialLoginResult {
                    return .notFoundInfo(result: socialLoginResult)
                } else {
                    return .completeError
                }
            default:
                return .appError(error: .unknownError)
            }
        case .parsing, .noResponse:
                return .appError(error: .unknownError)
        case .networkFailure:
            return .appError(error: .networkError)
        }
    }
}
