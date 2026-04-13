//
//  SignIn.swift
//  Mople
//
//  Created by CatSlave on 1/20/25.
//

import Foundation

public protocol SignIn {
    func execute(platform: LoginPlatform) async throws
}

public enum LoginError: Error {
    case appleAccountError
    case kakaoAccountError
    case completeError
    case notFoundInfo(result: SocialInfo)
    case cancle
    case handled
    case unknown(Error)

    public var info: String? {
        switch self {
        case .appleAccountError:
            return "설정에서 Apple 로그인 연동 해제 후\n다시 시도해 주세요."
        case .kakaoAccountError:
            return "카카오 계정과 연동을 실패했습니다.\n다시 시도해 주세요."
        case .completeError:
            return "로그인에 실패했어요.\n다시 시도해 주세요."
        case .unknown:
            return "요청에 실패했습니다.\n잠시 후 다시 시도해주세요."
        case .notFoundInfo, .cancle, .handled:
            return nil
        }
    }
}

public enum LoginPlatform: String {
    case apple = "APPLE"
    case kakao = "KAKAO"
}

public final class SignInUseCase: SignIn {

    /// 플랫폼별 소셜 로그인 서비스 (SocialLoginService 프로토콜)
    private let loginServices: [LoginPlatform: SocialLoginService]
    private let authenticationRepo: AuthenticationRepo

    public init(loginServices: [LoginPlatform: SocialLoginService],
         authenticationRepo: AuthenticationRepo) {
        self.loginServices = loginServices
        self.authenticationRepo = authenticationRepo
    }

    // MARK: - SignIn
    public func execute(platform: LoginPlatform) async throws {

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
public final class MockSignInUseCase: SignIn {
    public init() {}

    public func execute(platform: LoginPlatform) async throws {
        print("✅ [Mock] 로그인 요청 - platform: \(platform.rawValue)")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 로그인 성공")
    }
}
#endif
