//
//  CommonDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/4/25.
//

import UIKit

protocol CommonSceneFactory {
    // MARK: - UseCase
    func makeFetchUserInfoUseCase() -> FetchUserInfo
    func makeImageUploadUseCase() -> ImageUpload
    func makeDuplicateNicknameUseCase() -> CheckDuplicateNickname
    func makeFetchReviewDetailUseCase() -> FetchReviewDetail

    func makeMemberListViewController(type: MemberListType,
                                      coordinator: MemberListViewCoordination) -> MemberListViewController
    func makeCreateMeetViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    func makePlanCreateCoordinator(type: PlanCreationType) -> BaseCoordinator
    func makePlanDetailCoordinator(postId: Int,
                                   type: PlanDetailType) -> BaseCoordinator
    func makeReviewEditCoordinator(review: Review) -> BaseCoordinator
}

final class CommonDIContainer: CommonSceneFactory {
    
    private let appNetworkService: AppNetworkService
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
}

extension CommonDIContainer {
    
    // MARK: - 유저정보 로드 유즈케이스
    func makeFetchUserInfoUseCase() -> FetchUserInfo {
        return FetchUserInfoUseCase(userInfoRepo: makeUserInfoRepo())
    }
    
    private func makeUserInfoRepo() -> UserInfoRepo {
        return DefaultUserInfoRepo(networkService: appNetworkService)
    }
    
    
    // MARK: - 이미지 업로드 유즈케이스
    func makeImageUploadUseCase() -> ImageUpload {
        return ImageUploadUseCase(
            imageUploadRepo: makeImageUploadRepo()
        )
    }
    
    private func makeImageUploadRepo() -> ImageUploadRepo {
        return DefaultImageUploadRepo(networkService: appNetworkService)
    }
    
    // MARK: - 리뷰 정보 유즈케이스
    func makeFetchReviewDetailUseCase() -> FetchReviewDetail {
        return FetchReviewDetailUseCase(reviewListRepo: makeFetchReviewDetailRepo())
    }
    
    private func makeFetchReviewDetailRepo() -> ReviewQueryRepo {
        return DefaultReviewQueryRepo(networkService: appNetworkService)
    }
    
    // MARK: - 닉네임 중복검사
    func makeDuplicateNicknameUseCase() -> CheckDuplicateNickname {
        return CheckDuplicateNicknameUseCase(duplicateCheckRepo: makeNicknameManagerRepo())
    }

    private func makeNicknameManagerRepo() -> NicknameRepo {
        return DefaultNicknameManagerRepo(networkService: appNetworkService)
    }
    
    // MARK: - 그룹 생성 화면
    func makeCreateMeetViewController(coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return CreateMeetViewController(title: TextStyle.CreateGroup.title,
                                        reactor: makeCreateMeetViewReactor(coordinator: coordinator))
    }
    
    private func makeCreateMeetViewReactor(coordinator: MeetCreateViewCoordination) -> CreateMeetViewReactor {
        return .init(createMeetUseCase: makeCreateMeetUseCase(),
                     imageUploadUseCase: makeImageUploadUseCase(),
                     photoService: DefaultPhotoService(),
                     coordinator: coordinator)
    }
    
    private func makeCreateMeetUseCase() -> CreateMeet {
        return CreateMeetUseCase(createMeetRepo: makeCreateMeetRepo())
    }
    
    private func makeCreateMeetRepo() -> MeetCommandRepo {
        return DefaultMeetCommandRepo(networkService: appNetworkService)
    }
    
    // MARK: - 멤버 리스트 화면
    func makeMemberListViewController(type: MemberListType,
                                      coordinator: MemberListViewCoordination) -> MemberListViewController {
        return MemberListViewController(title: "참여자 목록",
                                        reactor: makeMemberListViewReactor(type: type,
                                                                           coordinator: coordinator))
    }
    
    private func makeMemberListViewReactor(type: MemberListType,
                                           coordinator: MemberListViewCoordination) -> MemberListViewReactor {
        return .init(type: type,
                     fetchPlanMemberUseCase: FetchPlanMemberMock(),
                     coordinator: coordinator)
    }
    
    // MARK: - 일정 생성 플로우
    func makePlanCreateCoordinator(type: PlanCreationType) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonFactory: self,
            type: type)
        return planCreateDI.makePlanCreateFlowCoordinator()
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailCoordinator(postId: Int,
                                   type: PlanDetailType) -> BaseCoordinator {
        let planDetailDI = PlanDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: self,
                                                      type: type,
                                                      postId: postId)
        return planDetailDI.makePlanDetailCoordinator()
    }
    
    // MARK: - 리뷰 편집 플로우
    func makeReviewEditCoordinator(review: Review) -> BaseCoordinator {
        let reviewEditDI = ReviewEditSceneDIContainer(
            appNetworkService: appNetworkService,
            commonFactory: self,
            review: review)
        return reviewEditDI.makeReviewEditCoordinator()
    }
}
