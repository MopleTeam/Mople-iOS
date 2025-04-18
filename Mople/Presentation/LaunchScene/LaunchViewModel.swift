//
//  LaunchViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/11/25.
//
import UIKit
import RxSwift

protocol LaunchViewModel: AnyObject {
    var error: Observable<Error?> { get }
    func checkEntry()
    func showSignInFlow()
}

final class DefaultLaunchViewModel: LaunchViewModel {
    
    private var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let errorSubject: PublishSubject<Error?> = .init()
    var error: Observable<Error?> {
        return errorSubject.asObservable()
    }
    
    // MARK: - Coordinator
    private weak var coordinator: LaunchCoordination?
    
    // MARK: - Usecase
    private let fetchUserInfo: FetchUserInfo
    
    // MARK: - LifeCycle
    init(fetchUserInfo: FetchUserInfo,
         coordinator: LaunchCoordination) {
        print(#function, #line, "LifeCycle Test DefaultLaunchViewModel Created" )

        self.fetchUserInfo = fetchUserInfo
        self.coordinator = coordinator
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DefaultLaunchViewModel Deinit" )
    }
    
    // MARK: - Account Check
    func checkEntry() {
        if JWTTokenStorage.shared.hasToken() {
            showMainFlow()
        } else {
            showSignInFlow()
        }
    }
    
    func showSignInFlow() {
        coordinator?.loginFlowStart()
    }
    
    private func showMainFlow() {
        if UserInfoStorage.shared.hasUserInfo {
            coordinator?.mainFlowStart(isFirstStart: false)
        } else {
            fetchUser()
        }
    }
    
    // MARK: - Data Request
    private func fetchUser() {
        fetchUserInfo.execute()
            .asObservable()
            .observe(on: MainScheduler.instance)
            .subscribe(with: self,
                       onNext: { vm, _ in
                vm.coordinator?.mainFlowStart(isFirstStart: false)
            }, onError: { vm, err in
                vm.errorSubject.onNext(err)
            })
            .disposed(by: disposeBag)
    }
}

