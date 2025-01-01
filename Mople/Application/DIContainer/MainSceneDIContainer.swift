//
//  MainSceneDIContainer.swift
//  Group
//
//  Created by CatSlave on 9/1/24.
//

import UIKit

final class MainSceneDIContainer: MainSceneDependencies {

    private lazy var FCMTokenManager: FCMTokenManager = {
        return .init(repo: DefaultFCMTokenRepo(networkService: appNetworkService))
    }()

    private let appNetworkService: AppNetworkService
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeMainFlowCoordinator(navigationController: UINavigationController) -> MainSceneCoordinator {
        let flow = MainSceneCoordinator(navigationController: navigationController,
                                     dependencies: self)
        return flow
    }
}

extension MainSceneDIContainer {
    // MARK: - 홈
    func makeHomeViewController(action: HomeViewAction) -> HomeViewController {
        let title = TextStyle.Tabbar.home
        
        let homeVC = HomeViewController(reactor: makeHomeViewReactor(action))
        homeVC.tabBarItem = .init(title: title, image: .home, selectedImage: nil)
        return homeVC
    }
    
    private func makeHomeViewReactor(_ action: HomeViewAction) -> HomeViewReactor {
        return HomeViewReactor(fetchRecentScheduleUseCase: FetchRecentScheduleMock(),
                               refreshFCMTokenUseCase: makeRefreshFCMTokenUseCase(),
                               viewAction: action)
    }
    
    private func makeRefreshFCMTokenUseCase() -> ReqseutRefreshFCMToken {
        return RefreshFCMTokenUseCase(tokenRefreshManager: FCMTokenManager)
    }
    
    // MARK: - 모임 리스트
    func makeGroupListViewController() -> GroupListViewController {
        let titel = TextStyle.Tabbar.group
        
        let groupListVC = GroupListViewController(title: titel,
                                                  reactor: makeGroupListViewReactor())
        groupListVC.tabBarItem = .init(title: titel, image: .people, selectedImage: nil)
        return groupListVC
    }
    
    private func makeGroupListViewReactor() -> GroupListViewReactor {
        return GroupListViewReactor(fetchUseCase: FetchGroupListMock())
    }
    
    // MARK: - 캘린더
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController {
        let title = TextStyle.Tabbar.calendar
        
        let calendarScheduleVC = CalendarScheduleViewController(title: title,
                                                                reactor: makeCalendarViewReactor())
        calendarScheduleVC.tabBarItem = .init(title: title, image: .tabBarCalendar, selectedImage: nil)
        return calendarScheduleVC
    }

    private func makeCalendarViewReactor() -> CalendarViewReactor {
        return CalendarViewReactor(fetchUseCase: FetchScheduleMock())
    }

    // MARK: - 프로필
    func makeProfileSceneCoordinator() -> BaseCoordinator {
        
        let profileDI = ProfileSceneDIContainer(appNetworkService: appNetworkService)
        
        let navigationController = UINavigationController()
        navigationController.isNavigationBarHidden = true
        navigationController.tabBarItem = .init(title: TextStyle.Tabbar.profile,
                                                image: .person,
                                                selectedImage: nil)
        
        return profileDI.makeSetupFlowCoordinator(navigationController: navigationController)
    }
    
    // MARK: - 프로필 편집
    func makeProfileEditViewController(previousProfile: ProfileInfo,
                                       action: ProfileEditAction) -> ProfileEditViewController {
        return .init(profile: previousProfile,
                     profileSetupReactor: makeProfileSetupReactor(),
                     editProfileReactor: makeProfileEditViewReactor(action))
    }
    
    private func makeProfileEditViewReactor(_ action: ProfileEditAction) -> ProfileEditViewReactor {
        return .init(profileEditUseCase: makeProfileEditUseCase(),
                     completedAction: action)
    }
    
    private func makeProfileEditUseCase() -> ProfileEdit {
        return ProfileEditUseCase(imageUploadRepo: makeImageUploadRepo(),
                                  profileEditRepo: makeProfileEditRepo())
    }
    
    private func makeImageUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkServbice: appNetworkService)
    }
    
    private func makeProfileEditRepo() -> ProfileEditRepo {
        return DefaultProfileEditRepo(networkService: appNetworkService)
    }
    
    
    // MARK: - 그룹 생성 화면
    func makeCreateGroupViewController(flowAction: CreatedGroupFlowAction) -> GroupCreateViewController {
        let title = TextStyle.CreateGroup.title
        return .init(title: title,
                     reactor: makeCreateGroupViewReactor(flowAction))
    }
    
    private func makeCreateGroupViewReactor(_ flowAction: CreatedGroupFlowAction) -> GroupCreateViewReactor {
        return .init(createGroupImpl: CreateGroupMock(),
                     flowAction: flowAction)
    }
    
    // MARK: - 일정 생성 화면
    func makePlanCreateDIContainer() -> PlanCreateSceneContainer {
        return PlanCreateSceneDIContainer(appNetworkService: appNetworkService)
    }
}

// MARK: - 프로필 셋업 Reactor
extension MainSceneDIContainer {
    private func makeProfileSetupReactor() -> ProfileSetupViewReactor {
        return .init(useCase: makeValidatorNicknameUsecase())
    }
    
    private func makeValidatorNicknameUsecase() -> ValidatorNickname {
        return ValidatorNicknameUseCase(repo: makeNicknameValidatorRepo())
    }
    
    private func makeNicknameValidatorRepo() -> NicknameValidationRepo {
        return DefaultNicknameValidationRepo(networkService: appNetworkService)
    }
}
