//
//  GroupDetailScene.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol MeetDetailCoordination: AnyObject {
    func swicthPlanListPage(isFuture: Bool)
    func pushMeetSetupView(meet: Meet)
    func popView()
    func endFlow()
}

final class MeetDetailSceneCoordinator: BaseCoordinator, MeetDetailCoordination {
    
    private let dependencies: MeetDetailSceneDependencies
    private var detailMeetVC: DetailMeetViewController?
    private var futurePlanListVC: FuturePlanListViewController?
    private var pastPlanListVC: PastPlanListViewController?
    
    init(dependencies: MeetDetailSceneDependencies,
         navigationController: UINavigationController) {
        print(#function, #line, "LifeCycle Test DetailMeetSceneCoordinator Created" )

        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DetailMeetSceneCoordinator Deinit" )
    }
    
    override func start() {
        detailMeetVC = dependencies.makeMeetDetailViewController(coordinator: self)
        navigationController.pushViewController(detailMeetVC!, animated: false)
        setPageViews()
    }
    
    private func setPageViews() {
        futurePlanListVC = dependencies.makeFuturePlanListViewController()
        pastPlanListVC = dependencies.makePastPlanListViewController()
        self.detailMeetVC?.pageController.setViewControllers([futurePlanListVC!], direction: .forward, animated: false)
    }
}

// MARK: - PageControl Setup
extension MeetDetailSceneCoordinator {
    func swicthPlanListPage(isFuture: Bool) {
        guard let vc = isFuture ? futurePlanListVC : pastPlanListVC,
              let currentVC = self.detailMeetVC?.pageController.viewControllers?.first,
              vc != currentVC else { return }
        
        let direction: UIPageViewController.NavigationDirection = isFuture ? .reverse : .forward
        
        self.detailMeetVC?.pageController.setViewControllers([vc], direction: direction, animated: true)
    }
}

// MARK: - Push View
extension MeetDetailSceneCoordinator {
    func pushMeetSetupView(meet: Meet) {
        let vc = dependencies.makeMeetSetupViewController(meet: meet,
                                                          coordinator: self)
        self.navigationController.pushViewController(vc, animated: true)
    }
}

// MARK: - Pop View
extension MeetDetailSceneCoordinator {
    func popView() {
        self.navigationController.popViewController(animated: true)
    }
}

// MARK: - End Flow
extension MeetDetailSceneCoordinator {
    
    func endFlow() {
        (self.parentCoordinator as? CreateMeetCoordination)?.closeSubView(completion: { [weak self] in
            self?.clear()
        })
    }
    
    private func clear() {
        self.clearUp()
        self.parentCoordinator?.didFinish(coordinator: self)
    }
}
