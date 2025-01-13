//
//  CommonDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import UIKit

protocol CommonSceneFactory {
    func makeProfileSetupReactor() -> ProfileSetupViewReactor
    func makeCreateMeetViewController(navigator: NavigationCloseable) -> CreateMeetViewController
    func makePlanCreateCoordinator(meetList: [MeetSummary]) -> BaseCoordinator
    func makePlanDetailCoordinator(plan: Plan) -> BaseCoordinator
}

final class CommonDIContainer: CommonSceneFactory {
    
    private let appNetworkService: AppNetworkService
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
}

extension CommonDIContainer {
    // MARK: - 프로필 설정 공통 리액터
    func makeProfileSetupReactor() -> ProfileSetupViewReactor {
        return .init(useCase: makeNicknameValidationUseCase())
    }
    
    private func makeNicknameValidationUseCase() -> ValidatorNickname {
        return ValidatorNicknameUseCase(repo: makeNicknameValidationRepo())
    }
    
    private func makeNicknameValidationRepo() -> NicknameValidationRepo {
        return DefaultNicknameValidationRepo(networkService: appNetworkService)
    }
    
    // MARK: - 그룹 생성 화면
    func makeCreateMeetViewController(navigator: NavigationCloseable) -> CreateMeetViewController {
        let createGroupVC = CreateMeetViewController(title: TextStyle.CreateGroup.title,
                                                      reactor: makeCreateMeetViewReactor(navigator: navigator))
        createGroupVC.modalPresentationStyle = .fullScreen
        return createGroupVC
    }
    
    private func makeCreateMeetViewReactor(navigator: NavigationCloseable) -> CreateMeetViewReactor {
        return .init(createMeetUseCase: makeCreateMeetUseCase(), // CreateGroupMock()
                     navigator: navigator)
    }
    
    private func makeCreateMeetUseCase() -> CreateMeet {
        return CreateMeetUseCase(imageUploadRepo: makeImageUploadRepo(),
                                  createMeetRepo: makeCreateMeetRepo())
    }
    
    private func makeImageUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkService: appNetworkService)
    }
    
    private func makeCreateMeetRepo() -> CreateMeetRepo {
        return DefaultCreateMeetRepo(networkService: appNetworkService)
    }
    
    // MARK: - 일정 생성 플로우
    func makePlanCreateCoordinator(meetList: [MeetSummary]) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            meetList: meetList)
        return planCreateDI.makePlanCreateFlowCoordinator()
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailCoordinator(plan: Plan) -> BaseCoordinator {
        let planDetailDI = PlanDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      plan: plan)
        return planDetailDI.makePlanDetailCoordinator()
    }
}
