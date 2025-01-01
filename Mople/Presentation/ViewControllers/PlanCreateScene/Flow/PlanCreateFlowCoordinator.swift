//
//  PlanCreateFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 12/23/24.
//

import UIKit

protocol PlanCreateFlow: AnyObject {
    func presentGroupSelectView()
    func presentDateSelectView()
    func presentTimeSelectView()
    func presentSearchLocationView()
    func endFlow(plan: Plan?)
}

protocol PlaceSelectionDelegate {
    func didSelectPlace(_ place: PlaceInfo?)
}

final class PlanCreateFlowCoordinator: BaseCoordinator, PlanCreateFlow {
    private let dependencies: PlanCreateSceneDependencies
    private var planCreateVC: PlanCreateViewController?
    
    init(navigationController: UINavigationController,
         dependencies: PlanCreateSceneDependencies) {
        print(#function, #line, "LifeCycle Test PlanCreateFlowCoordinator Created" )
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PlanCreateFlowCoordinator Deinit" )
    }
    
    override func start() {
        planCreateVC = dependencies.makePlanCreateViewController(flow: self)
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
        let searchLocationDI = dependencies.makeSearchLocationDIContainer()
        let navigationController = UINavigationController.createFullScreenNavigation()
        let flow = searchLocationDI.makeSearchLocationFlowCoordinator(navigationController: navigationController)
        self.start(coordinator: flow)
        self.navigationController.present(navigationController, animated: false)
    }
}

extension PlanCreateFlowCoordinator: PlaceSelectionDelegate {
    func didSelectPlace(_ place: PlaceInfo?) {
        guard let place else { return }
        planCreateVC?.setupPlace(place)
    }
}

// MARK: - End Flow
extension PlanCreateFlowCoordinator {
    func endFlow(plan: Plan?) {
        self.navigationController.dismiss(animated: false) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
