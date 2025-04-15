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
    func makeReportUseCase() -> ReportPost
    
    func makeMemberListViewController(type: MemberListType,
                                      coordinator: MemberListViewCoordination) -> MemberListViewController
    func makeCreateMeetViewController(isFlow: Bool,
                                      isEdit: Bool,
                                      type: MeetCreationType,
                                      coordinator: MeetCreateViewCoordination) -> CreateMeetViewController
    func makePlanCreateCoordinator(type: PlanCreationType,
                                   completionHandler: ((Plan) -> Void)?) -> BaseCoordinator
    func makeMeetDetailCoordiantor(meetId: Int) -> BaseCoordinator
    func makePlanDetailCoordinator(postId: Int,
                                   type: PlanDetailType) -> BaseCoordinator
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
        return FetchUserInfoUseCase(
            userInfoRepo: DefaultUserInfoRepo(networkService: appNetworkService)
        )
    }
    
    // MARK: - 이미지 업로드 유즈케이스
    func makeImageUploadUseCase() -> ImageUpload {
        return ImageUploadUseCase(
            imageUploadRepo: DefaultImageUploadRepo(networkService: appNetworkService)
        )
    }

    // MARK: - 리뷰 정보 유즈케이스
    func makeFetchReviewDetailUseCase() -> FetchReviewDetail {
        return FetchReviewDetailUseCase(
            repo: DefaultReviewQueryRepo(networkService: appNetworkService)
        )
    }
    
    // MARK: - 닉네임 중복검사
    func makeDuplicateNicknameUseCase() -> CheckDuplicateNickname {
        return CheckDuplicateNicknameUseCase(
            duplicateCheckRepo: DefaultNicknameManagerRepo(networkService: appNetworkService)
        )
    }
    
    // MARK: - 신고
    func makeReportUseCase() -> ReportPost {
        return ReportPostUseCase(
            repo: DefaultReportRepo(networkService: appNetworkService)
        )
    }
    
    // MARK: - 그룹 생성 화면
    func makeCreateMeetViewController(isFlow: Bool,
                                      isEdit: Bool,
                                      type: MeetCreationType,
                                      coordinator: MeetCreateViewCoordination) -> CreateMeetViewController {
        return CreateMeetViewController(isFlow: isFlow,
                                        isEdit: isEdit,
                                        title: makeCreateMeetViewTitle(type: type),
                                        reactor: makeCreateMeetViewReactor(type: type,
                                                                           coordinator: coordinator))
    }
    
    private func makeCreateMeetViewTitle(type: MeetCreationType) -> String {
        switch type {
        case .create:
            return "모임 생성하기"
        case .edit:
            return "모임 정보 수정"
        }
    }
    
    private func makeCreateMeetViewReactor(type: MeetCreationType,
                                           coordinator: MeetCreateViewCoordination) -> CreateMeetViewReactor {
        return .init(type: type,
                     createMeetUseCase: makeCreateMeetUseCase(),
                     editMeetUseCase: makeEditMeetUseCase(),
                     imageUploadUseCase: makeImageUploadUseCase(),
                     photoService: DefaultPhotoService(),
                     coordinator: coordinator)
    }
    
    private func makeCreateMeetUseCase() -> CreateMeet {
        return CreateMeetUseCase(createMeetRepo: makeMeetCommandRepo())
    }
    
    private func makeEditMeetUseCase() -> EditMeet {
        return EditMeetUseCase(repo: makeMeetCommandRepo())
    }
    
    private func makeMeetCommandRepo() -> MeetCommandRepo {
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
                     fetchMemberUseCase: makeFetchMemberUseCase(),
                     coordinator: coordinator)
    }
    
    private func makeFetchMemberUseCase() -> FetchMemberList {
        return FetchMemberUseCase(
            memberListRepo: DefaultFetchMemberList(networkService: appNetworkService)
        )
    }
    
    // MARK: - 일정 생성 플로우
    func makePlanCreateCoordinator(type: PlanCreationType,
                                   completionHandler: ((Plan) -> Void)?) -> BaseCoordinator {
        let planCreateDI = PlanCreateSceneDIContainer(
            appNetworkService: appNetworkService,
            commonFactory: self,
            type: type)
        return planCreateDI.makePlanCreateFlowCoordinator(completionHandler: completionHandler)
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailCoordinator(postId: Int,
                                   type: PlanDetailType) -> BaseCoordinator {
        let planDetailDI = PlanDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: self,
                                                      type: type,
                                                      id: postId)
        return planDetailDI.makePlanDetailCoordinator()
    }
    
    // MARK: - 모임 상세 뷰
    func makeMeetDetailCoordiantor(meetId: Int) -> BaseCoordinator {
        let meetDetailDI = MeetDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: self,
                                                      meetId: meetId)
        return meetDetailDI.makeMeetDetailCoordinator()
    }
}
