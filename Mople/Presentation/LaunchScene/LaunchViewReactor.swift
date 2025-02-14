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
}

final class DefaultLaunchViewModel: LaunchViewModel {
    
    private var disposeBag = DisposeBag()
    private let fetchUserInfo: FetchUserInfo
    private weak var coordinator: LaunchCoordination?
    
    init(fetchUserInfo: FetchUserInfo,
         coordinator: LaunchCoordination) {
        print(#function, #line, "LifeCycle Test DefaultLaunchViewModel Created" )

        self.fetchUserInfo = fetchUserInfo
        self.coordinator = coordinator
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultLaunchViewModel Deinit" )
    }
        
    func checkEntry() {
        if KeyChainService.shared.hasToken() {
            showMainFlow()
        } else {
            showSignInFlow()
        }
    }
    
    private func showSignInFlow() {
        Observable.just(())
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vm, _ in
                vm.coordinator?.loginFlowStart()
            })
            .disposed(by: disposeBag)
    }
    
    private func showMainFlow() {
        if UserInfoStorage.shared.hasUserInfo {
            coordinator?.mainFlowStart(isFirstStart: false)
        } else {
            fetchUser()
        }
    }
    
    private func fetchUser() {
        fetchUserInfo.execute()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { vm, _ in
                vm.coordinator?.mainFlowStart(isFirstStart: false)
            })
            .disposed(by: disposeBag)
    }
}

