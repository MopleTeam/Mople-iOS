//
//  CommonDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import UIKit

protocol CommonDependencies {
    func makeProfileSetupReactor() -> ProfileSetupViewReactor
}

final class CommonDIContainer: CommonDependencies {
    
    private let appNetworkService: AppNetworkService
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
}

extension CommonDIContainer {
    func makeProfileSetupReactor() -> ProfileSetupViewReactor {
        return .init(useCase: makeValidatorNicknameUsecase())
    }
    
    private func makeValidatorNicknameUsecase() -> ValidatorNickname {
        return ValidatorNicknameUseCase(repo: makeNicknameValidatorRepo())
    }
    
    private func makeNicknameValidatorRepo() -> NicknameValidationRepo {
        return DefaultNicknameValidationRepo(networkService: appNetworkService)
    }
}
