//
//  PlanCreateFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import UIKit

protocol PlanCreateCoordination: AnyObject {
    func presentGroupSelectView()
    func presentDateSelectView()
    func presentTimeSelectView()
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
        navigationController.pushViewController(planCreateVC!, animated: false)
    }
}

// MARK: - Picker View
extension PlanCreateFlowCoordinator {
    func presentGroupSelectView() {
        let vc = dependencies.makeGroupSelectViewController()
        navigationController.present(vc, animated: true)
    }
    
    func presentDateSelectView() {
        let vc = dependencies.makeDateSelectViewController()
        navigationController.present(vc, animated: true)
    }
    
    func presentTimeSelectView() {
        let vc = dependencies.makeTimeSelectViewController()
        navigationController.present(vc, animated: true)
    }
}

// MARK: - Search Loaction Flow
extension PlanCreateFlowCoordinator {
    func presentSearchLocationView() {
        let flow = dependencies.makeSearchLocationCoordinator()
        self.start(coordinator: flow)
        self.navigationController.presentWithTransition(flow.navigationController)
    }
}

// MARK: - End Flow
extension PlanCreateFlowCoordinator {
    
    func completed(with plan: Plan) {
        print(#function, #line, "성공했잖아?" )
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.completion?(plan)
            self?.clear()
        }
    }
    
    func endFlow() {
        print(#function, #line, "성공했는데..?" )
        self.navigationController.dismiss(animated: true) { [weak self] in
            self?.clear()
        }
    }
    
    private func clear() {
        self.clearUp()
        self.parentCoordinator?.didFinish(coordinator: self)
    }
}
