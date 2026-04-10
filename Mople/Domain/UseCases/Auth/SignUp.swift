//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

protocol SignUp {
    func execute(request: SignUpRequest) async throws
}

final class SignUpUseCase: SignUp, LifeCycleLoggable {

    private let repo: AuthenticationRepo

    init(repo: AuthenticationRepo) {
        self.repo = repo
        logLifeCycle()
    }

    deinit {
        logLifeCycle()
    }

    // MARK: - SignUp
    func execute(request: SignUpRequest) async throws {
        try await repo.signUp(requestModel: request)
    }
}

// MARK: - Mock UseCase
#if DEV
final class MockSignUpUseCase: SignUp {

    func execute(request: SignUpRequest) async throws {
        print("✅ [Mock] 회원가입 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 회원가입 성공")
    }
}
#endif
