//
//  PlanDetailFlowCoordinator.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit

typealias PostCoordination = PostDetailCoordination & CommentListCoordination

protocol PostDetailCoordination: AnyObject {
    func pushMemberListView(postId: Int)
    func pushPlaceDetailView(place: PlaceInfo)
    func pushReviewEditView(review: Review)
    func presentPhotoView(title: String?,
                          index: Int,
                          imagePaths: [String],
                          defaultType: UIImageView.DefaultImageType)
    func presentPlanEditFlow(plan: Plan)
    func endFlow()
}

protocol CommentListCoordination: NavigationCloseable {
    func presentWriterImageView(title: String?,
                                imagePath: String?,
                                defaultType: UIImageView.DefaultImageType)
    
    func pushReplyPage(parentComment: Comment, meetId: Int)
    func deleteParentComment(id: Int)
}

final class PostDetailFlowCoordinator: BaseCoordinator, PostDetailCoordination {

    private let dependencies: PostDetailSceneDependencies
    private var postVC: PostDetailViewController?
    
    init(dependencies: PostDetailSceneDependencies,
         navigationController: AppNaviViewController) {
        self.dependencies = dependencies
        super.init(navigationController: navigationController)
        setDismissGestureCompletion()
    }
    
    override func start() {
        postVC = dependencies.makePlanDetailViewController(coordinator: self)
        self.pushWithTracking(postVC!, animated: false)
    }
}

// MARK: - Member List View
extension PostDetailFlowCoordinator: MemberListViewCoordination {
    func pushMemberListView(postId: Int) {
        let vc = dependencies.makeMemberListViewController(coordinator: self)
        self.pushWithTracking(vc, animated: true)
    }
    
    func presentPhotoView(imagePath: String?) {
        let imagePaths = [imagePath].compactMap { $0 }
        self.presentPhotoView(title: nil,
                              index: 0,
                              imagePaths: imagePaths,
                              defaultType: .user)
    }
}

// MARK: - Review Edit View
extension PostDetailFlowCoordinator: ReviewEditViewCoordination {
    func pushReviewEditView(review: Review) {
        let vc = dependencies.makeReviewEditViewController(review: review,
                                                           coordinator: self)
        self.pushWithTracking(vc)
    }
}

// MARK: - Comment View
extension PostDetailFlowCoordinator: CommentListCoordination {
    func pushReplyPage(parentComment: Comment, meetId: Int) {
        let vc = dependencies.makeCommentListViewController(type: .child(parent: parentComment,
                                                                         meetId: meetId),
                                                            coordinator: self)
        self.push(vc, animated: true)
    }
    
    func deleteParentComment(id: Int) {
        postVC?.commentVC.deletedComment(id: id)
        self.pop()
    }
    
    func presentPhotoView(title: String?,
                          index: Int,
                          imagePaths: [String],
                          defaultType: UIImageView.DefaultImageType) {
        let vc = dependencies.makePhotoBookViewController(title: title,
                                                          imagePaths: imagePaths,
                                                          defaultType: defaultType)
        vc.selectedIndex = index
        self.presentWithTracking(vc)
    }
    
    func presentWriterImageView(title: String?,
                                imagePath: String?,
                                defaultType: UIImageView.DefaultImageType) {
        let imagePaths = [imagePath].compactMap { $0 }
        
        let vc = dependencies.makePhotoBookViewController(title: title,
                                                          imagePaths: imagePaths,
                                                          defaultType: defaultType)
        
        self.presentWithTracking(vc)
    }
}

// MARK: - Detail Place View
extension PostDetailFlowCoordinator: PlaceDetailCoordination {
    func pushPlaceDetailView(place: PlaceInfo) {
        let vc = dependencies.makePlaceDetailViewController(place: place,
                                                              coordinator: self)
        self.pushWithTracking(vc, animated: true)
    }
}

// MARK: - Flow
extension PostDetailFlowCoordinator {
    
    // 일정 수정 플로우
    func presentPlanEditFlow(plan: Plan) {
        let flow = dependencies.makePlanEditFlowCoordiantor(plan: plan)
        self.start(coordinator: flow)
        self.present(flow.navigationController)
    }
}

// MARK: - End Flow
extension PostDetailFlowCoordinator {
    func endFlow() {
        self.navigationController.dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.clearUp()
            self.parentCoordinator?.didFinish(coordinator: self)
        }
    }
}


