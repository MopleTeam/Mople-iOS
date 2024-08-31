//
//  CalenderFlowCoordinator.swift
//  Group
//
//  Created by CatSlave on 8/31/24.
//

import UIKit

protocol CalendarCoordinatorDependencies {
    func makeCalendarViewController() -> CalendarViewController
}

final class CalendarCoordinator: BaseCoordinator {
    private let dependencies: CalendarCoordinatorDependencies
    
    init(navigationController: UINavigationController,
         dependencies: CalendarCoordinatorDependencies) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let vc = dependencies.makeCalendarViewController()
        
        navigationController.pushViewController(vc, animated: true)
    }
}
