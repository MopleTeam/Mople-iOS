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
}

protocol PlaceSelectionDelegate {
    func didSelectPlace(_ place: PlaceInfo)
}

final class PlanCreateFlowCoordinator: BaseCoordinator, PlanCreateCoordination {
    private let dependencies: PlanCreateSceneDependencies
    private var planCreateVC: CreatePlanViewController?
    
    init(navigationController: AppNaviViewController,
         dependencies: PlanCreateSceneDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        planCreateVC = dependencies.makePlanCreateViewController(coordinator: self)
        navigationController.pushViewController(planCreateVC!, animated: false)
    }
}

// MARK: - Presnet VC
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

// MARK: - Present Flow
extension PlanCreateFlowCoordinator {
    func presentSearchLocationView() {
        let flow = dependencies.makeSearchLocationCoordinator()
        self.start(coordinator: flow)
        self.navigationController.presentWithTransition(flow.navigationController)
    }
}

// MARK: - SearchLoactionFlow로부터 주입받기
extension PlanCreateFlowCoordinator: PlaceSelectionDelegate {
    func didSelectPlace(_ place: PlaceInfo) {
        planCreateVC?.setupPlace(place)
    }
}

// MARK: - End Flow
extension PlanCreateFlowCoordinator {
    
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
