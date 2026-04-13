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
    /// 앱 버전 체크 후 강제 업데이트 여부 확인
    private func fetchAppVersion() {
        Task { [weak self] in
            do {
                let status = try await self?.checkAppVersionUseCase.executue()
                await MainActor.run {
                    if status?.forceUpdate == true {
                        self?.lauchErrorObservable.onNext(.forceUpdateRequired)
                    } else {
                        self?.checkEntry()
                    }
                }
            } catch {
                await MainActor.run {
                    self?.lauchErrorObservable.onNext(nil)
                }
            }
        }
    }

    /// 유저 정보 조회 후 메인/로그인 플로우 분기
    private func fetchUser() {
        Task { [weak self] in
            do {
                try await self?.fetchUserInfoUseCase.execute()
                await MainActor.run {
                    self?.coordinator?.mainFlowStart(isLogin: false)
                }
            } catch {
                await MainActor.run {
                    self?.resetUserData()
                    self?.coordinator?.loginFlowStart()
                }
            }
        }
    }
    
    private func resetUserData() {
        KeychainStorage.shared.deleteToken()
        UserInfoStorage.shared.deleteEnitity()
        UserDefaults.deleteFCMToken()
    }
}
