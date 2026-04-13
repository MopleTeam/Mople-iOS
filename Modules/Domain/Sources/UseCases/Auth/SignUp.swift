//
//  LoginUseCase.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

public protocol SignUp {
    func execute(request: SignUpRequest) async throws
}

public final class SignUpUseCase: SignUp, LifeCycleLoggable {

    private let repo: AuthenticationRepo

    public init(repo: AuthenticationRepo) {
        self.repo = repo
        logLifeCycle()
    }

    deinit {
        logLifeCycle()
    }

    // MARK: - SignUp
    public func execute(request: SignUpRequest) async throws {
        try await repo.signUp(requestModel: request)
    }
}

// MARK: - Mock UseCase
#if DEV
public final class MockSignUpUseCase: SignUp {
    public init() {}

    public func execute(request: SignUpRequest) async throws {
        print("✅ [Mock] 회원가입 요청")
        try await Task.sleep(nanoseconds: 1_000_000_000)
        print("✅ [Mock] 회원가입 성공")
    }
}
#endif
