//
//  SignIn.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

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

    /// 플랫폼별 소셜 로그인 서비스 (SocialLoginService 프로토콜)
    private let loginServices: [LoginPlatform: SocialLoginService]
    private let authenticationRepo: AuthenticationRepo

    init(loginServices: [LoginPlatform: SocialLoginService],
         authenticationRepo: AuthenticationRepo) {
        self.loginServices = loginServices
        self.authenticationRepo = authenticationRepo
    }

    // MARK: - SignIn
    func execute(platform: LoginPlatform) async throws {

        var socialLoginResult: SocialInfo?

        do {
            guard let service = loginServices[platform] else {
                throw LoginError.completeError
            }
            let accountInfo = try await service.login()
            socialLoginResult = accountInfo
            try await authenticationRepo.signIn(social: accountInfo)
        } catch {
            throw handleError(error, socialLoginResult)
        }
    }

    // MARK: - 에러 처리
    /// ServerErrorIdentifiable 프로토콜로 네트워크 에러를 분류
    /// (DataRequestError 등 Infrastructure 타입을 직접 참조하지 않음)
    private func handleError(_ error: Error,
                             _ socialLoginResult: SocialInfo?) -> LoginError {
        switch error {
        case let err as LoginError:
            return err
        case let serverError as ServerErrorIdentifiable where serverError.isNotFound:
            guard let socialLoginResult else { return .completeError }
            return .notFoundInfo(result: socialLoginResult)
        case is ServerErrorIdentifiable:
            return .handled
        default:
            return .unknown(error)
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
