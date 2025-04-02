//
//  AppCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit
import RxSwift

final class AppFlowCoordinator: BaseCoordinator {
    
    private let appDIContainer: AppDIContainer
    private var disposeBag = DisposeBag()
 
    init(navigationController: AppNaviViewController,
         appDIContainer: AppDIContainer) {
        self.appDIContainer = appDIContainer
        super.init(navigationController: navigationController)
        bindSessionExpiration()
    }
    
    override func start() {
        let launchView = appDIContainer.makeLaunchViewController(coordinator: self)
        self.navigationController.pushViewController(launchView, animated: false)
    }
}

// MARK: - 런치 스크린
protocol LaunchCoordination: AnyObject {
    func mainFlowStart(isFirstStart: Bool)
    func loginFlowStart()
}

extension AppFlowCoordinator: LaunchCoordination {
    func mainFlowStart(isFirstStart: Bool = false) {
        self.navigationController.viewControllers.removeAll()
        let mainSceneDIContainer = appDIContainer.makeMainSceneDIContainer(isFirstStart: isFirstStart)
        let flow = mainSceneDIContainer.makeMainFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
    }
    
    func loginFlowStart() {
        self.navigationController.viewControllers.removeAll()
        let loginSceneDIContainer = appDIContainer.makeLoginSceneDIContainer()
        let flow = loginSceneDIContainer.makeAuthFlowCoordinator(navigationController: navigationController)
        start(coordinator: flow)
    }
}

// MARK: - 로그인
protocol SignInListener {
    func signIn()
}

extension AppFlowCoordinator: SignInListener {
    func signIn() {
        mainFlowStart(isFirstStart: true)
    }
}

// MARK: - 로그아웃, 회원탈퇴
protocol SignOutListener {
    func signOut()
}

extension AppFlowCoordinator: SignOutListener {
    func signOut() {
        KeyChainService.shared.deleteToken()
        UserInfoStorage.shared.deleteEnitity()
        loginFlowStart()
    }
}

// MARK: - 로그인 세션 만료
extension AppFlowCoordinator {
    private func bindSessionExpiration() {
        EventService.shared.addObservable(name: .sessionExpired)
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.loginFlowStart()
            })
            .disposed(by: disposeBag)
    }
}


    

