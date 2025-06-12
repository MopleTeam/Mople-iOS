//
//  LaunchViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/11/25.
//
import UIKit
import RxSwift

protocol LaunchViewModel: AnyObject {
    var errObservable: Observable<LaunchError?> { get }
    func checkAppVersion()
}

enum LaunchError: Error {
    case forceUpdateRequired
}

final class DefaultLaunchViewModel: LaunchViewModel {
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let lauchErrorObservable: PublishSubject<LaunchError?> = .init()
    var errObservable: Observable<LaunchError?> {
        lauchErrorObservable
    }
    
    // MARK: - Coordinator
    private weak var coordinator: LaunchCoordination?
    
    // MARK: - Usecase
    private let fetchUserInfoUseCase: FetchUserInfo
    private let checkAppVersionUseCase: CheckVersion
    
    // MARK: - LifeCycle
    init(fetchUserInfoUseCase: FetchUserInfo,
         checkAppVersionUseCase: CheckVersion,
         coordinator: LaunchCoordination) {
        print(#function, #line, "LifeCycle Test DefaultLaunchViewModel Created" )
        self.fetchUserInfoUseCase = fetchUserInfoUseCase
        self.checkAppVersionUseCase = checkAppVersionUseCase
        self.coordinator = coordinator
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultLaunchViewModel Deinit" )
    }
    
    // MARK: - Version & Token Check
    func checkAppVersion() {
        fetchAppVersion()
    }
    
    private func checkEntry() {
        if KeychainStorage.shared.hasToken() {
            fetchUser()
        } else {
            coordinator?.loginFlowStart()
        }
    }
    
    // MARK: - Data Request
    private func fetchAppVersion() {
        checkAppVersionUseCase.executue()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vm, status in
                if status.forceUpdate {
                    vm.lauchErrorObservable.onNext(.forceUpdateRequired)
                } else {
                    vm.checkEntry()
                }
            })
            .disposed(by: disposeBag)
    }
 
    
    private func fetchUser() {
        fetchUserInfoUseCase.execute()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self,
                       onNext: { vm, test in
                vm.coordinator?.mainFlowStart(isLogin: false)
            }, onError: { vm, err in
                vm.resetUserData()
                vm.coordinator?.loginFlowStart()
            })
            .disposed(by: disposeBag)
    }
    
    private func resetUserData() {
        KeychainStorage.shared.deleteToken()
        UserInfoStorage.shared.deleteEnitity()
        UserDefaults.deleteFCMToken()
    }
}
