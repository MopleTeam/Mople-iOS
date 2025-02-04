//
//  AppFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/22/24.
//

import UIKit

protocol Coordinator: AnyObject {
    var navigationController: AppNaviViewController { get set }
    var parentCoordinator: Coordinator? { get set }
    func start()
    func start(coordinator: Coordinator)
    func didFinish(coordinator: Coordinator)
}

class BaseCoordinator: Coordinator, LifeCycleLoggable, NavigationCloseable {
    
    var childCoordinators: [Coordinator] = []
    var parentCoordinator: Coordinator?
    var navigationController: AppNaviViewController
    
    init(navigationController: AppNaviViewController) {
        self.navigationController = navigationController
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func start() {
        fatalError("Start method must be implemented")
    }
    
    func start(coordinator: Coordinator) {
        self.childCoordinators.append(coordinator)
        coordinator.parentCoordinator = self
        coordinator.start()
    }
    
    func didFinish(coordinator: Coordinator) {
        if let index = self.childCoordinators.firstIndex(where: { $0 === coordinator }) {
            self.childCoordinators.remove(at: index)
        }
    }
    
    func clearUp() {
        self.childCoordinators.forEach {
            $0.navigationController.viewControllers.removeAll()
            self.didFinish(coordinator: $0)
        }
        
        self.childCoordinators.removeAll()
        self.navigationController.viewControllers.removeAll()
    }
    
    func dismiss() {
        self.navigationController.dismiss(animated: true)
    }
    
    func pop() {
        self.navigationController.popViewController(animated: true)
    }
}

// MARK: - Gesture
extension BaseCoordinator {
    func setDismissGestureCompletion() {
        self.navigationController.setupDismissCompletion { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}

// MARK: - Fade 효과로 전환하기
extension BaseCoordinator {
    func fadeOut(completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.5) {
                UIApplication.shared.keyWindow?.layer.opacity = 0
            } completion: { _ in
                completion?()
                UIView.animate(withDuration: 0.5) {
                    UIApplication.shared.keyWindow?.layer.opacity = 1
                }
            }
        }
    }
}




