//
//  SignIn.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import RxSwift

protocol SignIn {
    func execute(platform: LoginPlatform) async throws
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
    func execute(platform: LoginPlatform) async throws {

        var socialLoginResult: SocialInfo?

        do {
            let accountInfo = try await handleLogin(platform)
            socialLoginResult = accountInfo
            try await authenticationRepo.signIn(social: accountInfo)
        } catch {
            throw handleError(error, socialLoginResult)
        }
    }

    /// 플랫폼별 소셜 로그인을 실행하고 결과를 반환한다
    /// - Note: 로그인 서비스가 RxSwift(Single/Observable) 기반이므로 withCheckedThrowingContinuation으로 브릿지
    private func handleLogin(_ platform: LoginPlatform) async throws -> SocialInfo {
        switch platform {
        case .apple:
            return try await bridgeAppleLogin()
        case .kakao:
            return try await bridgeKakaoLogin()
        }
    }

    /// Apple 로그인 Single<SocialInfo>를 async throws로 변환
    private func bridgeAppleLogin() async throws -> SocialInfo {
        try await withCheckedThrowingContinuation { continuation in
            _ = appleLoginService.startAppleLogin()
                .subscribe(onSuccess: { socialInfo in
                    continuation.resume(returning: socialInfo)
                }, onFailure: { error in
                    continuation.resume(throwing: error)
                })
        }
    }

    /// 카카오 로그인 Observable<SocialInfo>를 async throws로 변환
    private func bridgeKakaoLogin() async throws -> SocialInfo {
        try await withCheckedThrowingContinuation { continuation in
            var resumed = false
            _ = kakaoLoginService.startKakaoLogin()
                .take(1)
                .subscribe(onNext: { socialInfo in
                    guard !resumed else { return }
                    resumed = true
                    continuation.resume(returning: socialInfo)
                }, onError: { error in
                    guard !resumed else { return }
                    resumed = true
                    continuation.resume(throwing: error)
                })
        }
    }

    private func handleError(_ error: Error,
                             _ socialLoginResult: SocialInfo?) -> LoginError {
        switch error {
        case let err as LoginError:
            return err
        case let transferError as DataRequestError:
            return handleTransferError(transferError, socialLoginResult: socialLoginResult)
        default:
            return .unknown(error)
        }
    }

    private func handleTransferError(_ error: DataRequestError, socialLoginResult: SocialInfo?) -> LoginError {
        switch error {
        case .noResponse:
            guard let socialLoginResult else { return .completeError }
            return .notFoundInfo(result: socialLoginResult)
        default:
            return .handled
        }
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockSignInUseCase: SignIn {

    func execute(platform: LoginPlatform) async throws {
        print("✅ [Mock] 로그인 요청 - platform: \(platform.rawValue)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 로그인 성공")
    }
}
#endif
