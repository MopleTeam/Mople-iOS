//
//  TransferMeetFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import UIKit
import Domain

protocol TransferMeetFlowCoordination: AnyObject {
    func showTransferMeet(meet: Meet)
    func completeAllTransfers()  // 모든 양도 완료
    func endFlow()  // 플로우 종료 (뒤로가기 등)
    func endMainFlow()
}

final class TransferMeetFlowCoordinator: BaseCoordinator, TransferMeetFlowCoordination {
    
    private let dependencies: TransferMeetSceneDependencies
    private let onComplete: () -> Void  // 모든 양도 완료 콜백
    
    init(navigationController: AppNaviViewController,
         dependencies: TransferMeetSceneDependencies,
         onComplete: @escaping () -> Void) {
        self.dependencies = dependencies
        self.onComplete = onComplete
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        let listView = dependencies.makeTransferMeetListView(coordinator: self)
        push(listView, animated: false)
    }
    
    // MARK: - Navigation
    func showTransferMeet(meet: Meet) {
        let transferView = dependencies.makeTransferMeetView(meet: meet)
        pushWithTracking(transferView, animated: true)
    }
    
    // MARK: - Complete All Transfers
    func completeAllTransfers() {
        // 모든 양도 완료 → ProfileFlow로 탈퇴 진행 알림
        endFlow()
        onComplete()
    }
    
    // MARK: - Delete Account
  
    func endMainFlow() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            (self.parentCoordinator as? ProfileCoordination)?.endMainFlow()
        }
    }

    // MARK: - End Flow (MeetDetailSceneCoordinator 참고)
    func endFlow() {
        navigationController.dismiss(animated: true) { [weak self] in
            self?.clear()
        }
    }
    
    private func clear() {
        clearUp()
        parentCoordinator?.didFinish(coordinator: self)
    }
}
