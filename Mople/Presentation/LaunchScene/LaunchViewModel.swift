//
//  LaunchViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/11/25.
//
import UIKit
import RxSwift

protocol LaunchViewModel: AnyObject {
    func checkEntry()
    func showSignInFlow()
}

final class DefaultLaunchViewModel: LaunchViewModel {
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Coordinator
    private weak var coordinator: LaunchCoordination?
    
    // MARK: - Usecase
    private let fetchUserInfoUseCase: FetchUserInfo
    
    // MARK: - LifeCycle
    init(fetchUserInfoUseCase: FetchUserInfo,
         coordinator: LaunchCoordination) {
        print(#function, #line, "LifeCycle Test DefaultLaunchViewModel Created" )
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.coordinator = coordinator
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultLaunchViewModel Deinit" )
    }
    
    // MARK: - Account Check
    func checkEntry() {
        if KeychainStorage.shared.hasToken() {
            fetchUser()
        } else {
            showSignInFlow()
        }
    }
    
    func showSignInFlow() {
        coordinator?.loginFlowStart()
    }
    
    private func fetchUser() {
        fetchUserInfoUseCase.execute()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self,
                       onNext: { vm, test in
                vm.coordinator?.mainFlowStart(isLogin: false)
            }, onError: { vm, err in
                vm.resetUserData()
                vm.showSignInFlow()
            })
            .disposed(by: disposeBag)
    }
    
    private func resetUserData() {
        KeychainStorage.shared.deleteToken()
        UserInfoStorage.shared.deleteEnitity()
        UserDefaults.deleteFCMToken()
    }
}
