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

// MARK: - 멤버 리스트
extension PlanDetailFlowCoordinator: MemberListViewCoordination {
    func pushMemberListView(postId: Int) {
        let view = dependencies.makeMemberListViewController(coordinator: self)
        navigationController.pushViewController(view, animated: true)
    }
}

// MARK: - 포토북
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

// MARK: - 상세 지도
extension PlanDetailFlowCoordinator: PlaceDetailCoordination {
    func pushPlaceDetailView(place: PlaceInfo) {
        let view = dependencies.makePlaceDetailViewController(place: place,
                                                              coordinator: self)
        navigationController.pushViewController(view, animated: true)
    }
}

// MARK: - Present(플로우 전환)
extension PlanDetailFlowCoordinator {
    func presentPlanEditFlow(plan: Plan) {
        let flow = dependencies.makePlanEditFlowCoordiantor(plan: plan)
        self.start(coordinator: flow)
        self.navigationController.presentWithTransition(flow.navigationController)
    }
    
    func presentReviewEditFlow(review: Review) {
        let flow = dependencies.makeReviewEditFlowCoordinator(review: review)
        self.start(coordinator: flow)
        self.navigationController.presentWithTransition(flow.navigationController)
    }
}

// MARK: - 플로우 종료
extension PlanDetailFlowCoordinator {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}
