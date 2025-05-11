//
//  CalendarFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import UIKit

protocol CalendarCoordination: AnyObject {
    func pushPostDetailView(postId: Int,
                            type: PostType)
}

final class CalendarFlowCoordinator: BaseCoordinator, CalendarCoordination {
    
    private let dependencies: CalendarSceneDependencies
    
    init(navigationController: AppNaviViewController,
         dependency: CalendarSceneDependencies) {
        self.dependencies = dependency
        super.init(navigationController: navigationController)
    }
    
    override func start() {
        let calendarVC = makeMainViewController()
        self.push(calendarVC, animated: false)
    }
}

// MARK: - Default View
extension CalendarFlowCoordinator {
    private func makeMainViewController() -> CalendarPostViewController {
        return dependencies.makeCalendarScheduleViewcontroller(coordinator: self)
    }
}

// MARK: - Flow
extension CalendarFlowCoordinator {
    func pushPostDetailView(postId: Int,
                            type: PostType) {
        let planDetailFlowCoordinator = dependencies.makePlanDetailFlowCoordinator(postId: postId,
                                                                                   type: type)
        start(coordinator: planDetailFlowCoordinator)
        self.present(planDetailFlowCoordinator.navigationController)
    }
}
