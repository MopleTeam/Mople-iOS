//
//  GroupDetailScene.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit

protocol DetailMeetCoordination: AnyObject {
    func swicthPlanListPage(isFuture: Bool)
    func endFlow()
}

final class DetailMeetSceneCoordinator: BaseCoordinator, DetailMeetCoordination {
    
    private let dependencies: DetailMeetSceneDependencies
    private var detailMeetVC: DetailMeetViewController?
    private var futurePlanListVC: FuturePlanListViewController?
    private var pastPlanListVC: PastPlanListViewController?
    
    init(dependencies: DetailMeetSceneDependencies,
         navigationController: UINavigationController) {
        print(#function, #line, "LifeCycle Test DetailMeetSceneCoordinator Created" )

        self.dependencies = dependencies
        super.init(navigationController: navigationController)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DetailMeetSceneCoordinator Deinit" )
    }
    
    override func start() {
        detailMeetVC = dependencies.makeDetailMeetViewController(coordinator: self)
        navigationController.pushViewController(detailMeetVC!, animated: false)
        setPageViews()
    }
    
    private func setPageViews() {
        futurePlanListVC = dependencies.makeFuturePlanListViewController()
        pastPlanListVC = dependencies.makePastPlanListViewController()
        self.detailMeetVC?.pageController.setViewControllers([futurePlanListVC!], direction: .forward, animated: false)
    }
}

extension DetailMeetSceneCoordinator {
    func swicthPlanListPage(isFuture: Bool) {
        guard let vc = isFuture ? futurePlanListVC : pastPlanListVC,
              let currentVC = self.detailMeetVC?.pageController.viewControllers?.first,
              vc != currentVC else { return }
        
        let direction: UIPageViewController.NavigationDirection = isFuture ? .reverse : .forward
        
        self.detailMeetVC?.pageController.setViewControllers([vc], direction: direction, animated: true)
    }
}

// MARK: - End Flow
extension DetailMeetSceneCoordinator {
    
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
