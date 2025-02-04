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
    func makeMemberListViewController(type: MemberListViewType,
                                      coordinator: MemberListCoordination) -> MemberListViewController
    func makeCreateMeetViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    func makePlanCreateCoordinator(type: PlanCreationType) -> BaseCoordinator
    func makePlanDetailCoordinator(postId: Int,
                                   type: PlanDetailType) -> BaseCoordinator
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
    func makeCreateMeetViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return CreateMeetViewController(title: TextStyle.CreateGroup.title,
                                        reactor: makeCreateMeetViewReactor(coordinator: coordinator))
    }
    
    private func makeCreateMeetViewReactor(coordinator: MeetCreateViewCoordination) -> CreateMeetViewReactor {
        return .init(createMeetUseCase: makeCreateMeetUseCase(),
                     imageUploadUseCase: makeImageUploadUseCase(),
                     coordinator: coordinator)
    }
    
    private func makeCreateMeetUseCase() -> CreateMeet {
        return CreateMeetUseCase(createMeetRepo: makeCreateMeetRepo())
    }
    
    private func makeCreateMeetRepo() -> MeetCommandRepo {
        return DefaultMeetCommandRepo(networkService: appNetworkService)
    }
    
    // MARK: - 멤버 리스트 화면
    func makeMemberListViewController(type: MemberListViewType,
                                      coordinator: MemberListCoordination) -> MemberListViewController {
        return MemberListViewController(title: "참여자 목록",
                                        reactor: makeMemberListViewReactor(type: type,
                                                                           coordinator: coordinator))
    }
    
    private func makeMemberListViewReactor(type: MemberListViewType,
                                           coordinator: MemberListCoordination) -> MemberListViewReactor {
        return .init(type: type,
                     fetchPlanMemberUseCase: FetchPlanMemberMock(),
                     coordinator: coordinator)
    }
    
    // MARK: - 일정 생성 플로우
    func makePlanCreateCoordinator(type: PlanCreationType) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonFactory: self,
            type: type)
        return planCreateDI.makePlanCreateFlowCoordinator()
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailCoordinator(postId: Int,
                                   type: PlanDetailType) -> BaseCoordinator {
        print(#function, #line, "#55 : \(type) ")
        let planDetailDI = PlanDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: self,
                                                      postId: postId)
        return planDetailDI.makePlanDetailCoordinator(type: type)
    }
}
