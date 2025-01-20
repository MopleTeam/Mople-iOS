//
//  CommonDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import UIKit

protocol CommonSceneFactory {
    func makeImageUploadUseCase() -> ImageUpload
    func makeProfileSetupReactor(profile: UserInfo?,
                                 shouldGenerateNickname: Bool) -> ProfileSetupViewReactor
    func makeCreateMeetViewController(navigator: NavigationCloseable) -> CreateMeetViewController
    func makePlanCreateCoordinator(meetList: [MeetSummary]) -> BaseCoordinator
    func makePlanDetailCoordinator(planId: Int) -> BaseCoordinator
}

final class CommonDIContainer: CommonSceneFactory {
    
    private let appNetworkService: AppNetworkService
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
}

extension CommonDIContainer {
    
    // MARK: - 이미지 업로드 유즈케이스
    func makeImageUploadUseCase() -> ImageUpload {
        return ImageUploadUseCase(
            imageUploadRepo: makeImageUploadRepo()
        )
    }
    
    private func makeImageUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkService: appNetworkService)
    }
    
    // MARK: - 프로필 설정 공통 리액터
    func makeProfileSetupReactor(profile: UserInfo?,
                                 shouldGenerateNickname: Bool) -> ProfileSetupViewReactor {
        return .init(profile: profile,
                     validativeNicknameUseCase: makeValidateNicknameUseCase(),
                     generateNicknameUseCase: makeGenerateNicknameUseCase())
    }
    
    private func makeValidateNicknameUseCase() -> ValidativeNickname {
        return NicknameManagerUseCase(nickNameRepo: makeNicknameManagerRepo())
    }
    
    private func makeGenerateNicknameUseCase() -> GenerativeNickname {
        return GenerateNicknameUseCase(nickNameRepo: makeNicknameManagerRepo())
    }
    
    private func makeNicknameManagerRepo() -> NicknameRepo {
        return DefaultNicknameManagerRepo(networkService: appNetworkService)
    }
    
    // MARK: - 그룹 생성 화면
    func makeCreateMeetViewController(navigator: NavigationCloseable) -> CreateMeetViewController {
        return CreateMeetViewController(title: TextStyle.CreateGroup.title,
                                        reactor: makeCreateMeetViewReactor(navigator: navigator))
    }
    
    private func makeCreateMeetViewReactor(navigator: NavigationCloseable) -> CreateMeetViewReactor {
        return .init(createMeetUseCase: makeCreateMeetUseCase(),
                     imageUploadUseCase: makeImageUploadUseCase(),
                     navigator: navigator)
    }
    
    private func makeCreateMeetUseCase() -> CreateMeet {
        return CreateMeetUseCase(createMeetRepo: makeCreateMeetRepo())
    }
    
    private func makeCreateMeetRepo() -> MeetCommandRepo {
        return DefaultMeetCommandRepo(networkService: appNetworkService)
    }
    
    // MARK: - 일정 생성 플로우
    func makePlanCreateCoordinator(meetList: [MeetSummary]) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            meetList: meetList)
        return planCreateDI.makePlanCreateFlowCoordinator()
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailCoordinator(planId: Int) -> BaseCoordinator {
        let planDetailDI = PlanDetailSceneDIContainer(appNetworkService: appNetworkService, planId: planId)
        return planDetailDI.makePlanDetailCoordinator()
    }
}
