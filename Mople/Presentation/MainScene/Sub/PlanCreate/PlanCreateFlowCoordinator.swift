//
//  PlanCreateFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import UIKit

protocol PlanCreateCoordination: AnyObject {
    func presentSearchLocationView()
    func endFlow()
    func completed(with plan: Plan)
}

final class PlanCreateFlowCoordinator: BaseCoordinator, PlanCreateCoordination {
    
    private let dependencies: PlanCreateSceneDependencies
    private var planCreateVC: CreatePlanViewController?
    private let completion: ((Plan) -> Void)?
    
    init(navigationController: AppNaviViewController,
         dependencies: PlanCreateSceneDependencies,
         completionHandler: ((Plan) -> Void)? = nil) {
        self.dependencies = dependencies
        self.completion = completionHandler
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        planCreateVC = dependencies.makePlanCreateViewController(coordinator: self)
        self.pushWithTracking(planCreateVC!, animated: false)
    }
}

// MARK: - Search Loaction Flow
extension PlanCreateFlowCoordinator {
    func presentSearchLocationView() {
        let flow = dependencies.makeSearchLocationCoordinator()
        self.start(coordinator: flow)
        self.present(flow.navigationController)
    }
}

// MARK: - End Flow
extension PlanCreateFlowCoordinator {
    
    func completed(with plan: Plan) {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.completion?(plan)
            self?.clear()
        }
    }
    
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.clear()
        }
    }
    
    private func clear() {
        self.clearUp()
        self.parentCoordinator?.didFinish(coordinator: self)
    }
}
