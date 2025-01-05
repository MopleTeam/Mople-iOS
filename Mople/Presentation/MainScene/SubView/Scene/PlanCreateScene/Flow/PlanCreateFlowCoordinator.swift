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
    func endProcess()
    func completedProcess(plan: Plan)
}

protocol PlaceSelectionDelegate {
    func didSelectPlace(_ place: PlaceInfo)
}

final class PlanCreateFlowCoordinator: BaseCoordinator, PlanCreateCoordination {
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
        let searchLocationDI = dependencies.makeSearchLocationDIContainer()
        let navigationController = UINavigationController.createFullScreenNavigation()
        let flow = searchLocationDI.makeSearchLocationFlowCoordinator(navigationController: navigationController)
        self.start(coordinator: flow)
        self.navigationController.present(navigationController, animated: false)
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
    
    func endProcess() {
        (self.parentCoordinator as? GroupCreateCoordination)?.closeSubView(completion: { [weak self] in
            self?.clear()
        })
    }
    
    func completedProcess(plan: Plan) {
        (self.parentCoordinator as? GroupCreateCoordination)?.completedAndSwitchGroupTap(completion: { [weak self] in
            self?.clear()
        })
    }
    
    private func clear() {
        self.clearUp()
        self.parentCoordinator?.didFinish(coordinator: self)
    }
}
