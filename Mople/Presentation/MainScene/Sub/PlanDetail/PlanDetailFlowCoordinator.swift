//
//  PlanDetailFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

protocol PlanDetailCoordination: AnyObject {
    func pushMemberListView(postId: Int)
    func pushPlaceDetailView(place: PlaceInfo)
    func pushPhotoView(index: Int,
                       imagePaths: [String])
    func presentPlanEditFlow(plan: Plan)
    func presentReviewEditFlow(review: Review)
    func endFlow()
}

final class PlanDetailFlowCoordinator: BaseCoordinator, PlanDetailCoordination {

    private let dependencies: PlanDetailSceneDependencies
    
    init(dependencies: PlanDetailSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        let planDetailVC = makePlanDetailViewController()
        navigationController.pushViewController(planDetailVC, animated: false)
    }
}

// MARK: - Default View
extension PlanDetailFlowCoordinator {
    private func makePlanDetailViewController() -> PlanDetailViewController {
        let planDetailVC = dependencies.makePlanDetailViewController(coordinator: self)
        let commentListContainer = planDetailVC.commentContainer
        self.addCommentListView(parentVC: planDetailVC, container: commentListContainer)
        return planDetailVC
    }
    
    private func addCommentListView(parentVC: PlanDetailViewController, container: UIView) {
        let commentListVC = dependencies.makeCommentListViewController()
        parentVC.commentListView = commentListVC
        parentVC.add(child: commentListVC, container: container)
    }
}

// MARK: - Member List View
extension PlanDetailFlowCoordinator: MemberListViewCoordination {
    func pushMemberListView(postId: Int) {
        let view = dependencies.makeMemberListViewController(coordinator: self)
        navigationController.pushViewController(view, animated: true)
    }
}

// MARK: - Photo View
extension PlanDetailFlowCoordinator {
    func pushPhotoView(index: Int,
                       imagePaths: [String]) {
        print(#function, #line)
        let view = dependencies.makePhotoBookViewController(imagePaths: imagePaths,
                                                            index: index,
                                                            coordinator: self)
        navigationController.pushViewController(view, animated: true)
    }
}

// MARK: - Detail Place View
extension PlanDetailFlowCoordinator: PlaceDetailCoordination {
    func pushPlaceDetailView(place: PlaceInfo) {
        let view = dependencies.makePlaceDetailViewController(place: place,
                                                              coordinator: self)
        navigationController.pushViewController(view, animated: true)
    }
}

// MARK: - Flow
extension PlanDetailFlowCoordinator {
    
    // 일정 수정 플로우
    func presentPlanEditFlow(plan: Plan) {
        let flow = dependencies.makePlanEditFlowCoordiantor(plan: plan)
        self.start(coordinator: flow)
        self.navigationController.presentWithTransition(flow.navigationController)
    }
    
    // 리뷰 수정 플로우
    func presentReviewEditFlow(review: Review) {
        let flow = dependencies.makeReviewEditFlowCoordinator(review: review)
        self.start(coordinator: flow)
        self.navigationController.presentWithTransition(flow.navigationController)
    }
}

// MARK: - End Flow
extension PlanDetailFlowCoordinator {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
