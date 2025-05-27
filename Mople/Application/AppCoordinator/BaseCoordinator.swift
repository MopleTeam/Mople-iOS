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
    func resetChildCoordinators(completion: (() -> Void)?)
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
    
    func resetChildCoordinators(completion: (() -> Void)?) {
        self.navigationController.dismiss(animated: true,
                                          completion: { [weak self] in
            guard let self,
                  !self.childCoordinators.isEmpty else {
                completion?()
                return
            }
            
            childCoordinators.forEach {
                $0.navigationController.viewControllers.removeAll()
                self.didFinish(coordinator: $0)
            }
            
            childCoordinators.removeAll()
            completion?()
        })
    }
}

// MARK: - Navigation
extension BaseCoordinator {
    
    // MARK: - Start
    func present(_ viewController: UIViewController,
                 completion: (() -> Void)? = nil) {
        self.navigationController.presentWithTransition(viewController,
                                                        completion: completion)
    }
    
    func push(_ viewController: UIViewController,
              animated: Bool = true) {
        self.navigationController.pushViewController(viewController,
                                                     animated: animated)
    }
    
    // MARK: - Start With Tracking
    func pushWithTracking(_ viewController: UIViewController,
                          animated: Bool = true) {
        self.push(viewController, animated: animated)
        ScreenTracking.track(with: viewController)
    }
    
    func presentWithTracking(_ viewController: UIViewController,
                             animated: Bool = true,
                             completion: (() -> Void)? = nil) {
        self.navigationController.present(viewController,
                                          animated: animated,
                                          completion: completion)
    }
    
    func slidePresentWithTracking(_ viewController: UIViewController,
                             completion: (() -> Void)? = nil) {
        self.present(viewController, completion: completion)
        ScreenTracking.track(with: viewController)
    }
    
    // MARK: - End
    func dismiss(completion: (() -> Void)?) {
        self.navigationController.dismiss(animated: true,
                                          completion: completion)
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

// MARK: - Hleper
extension BaseCoordinator {
    func findChildCoordinator<C: Coordinator>(ofType type: C.Type) -> C? {
        return childCoordinators
            .filter { $0 is C }
            .first as? C
    }
}




