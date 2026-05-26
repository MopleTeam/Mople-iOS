//
//  NoticeSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SwiftUI
import Domain
import Data

protocol NoticeSceneDependencies {
    func makeNoticeListViewController(meetId: Int,
                                      isCreator: Bool,
                                      coordinator: NoticeFlowCoordination) -> UIViewController
    func makeNoticeDetailViewController(notice: Notice,
                                        isCreator: Bool,
                                        coordinator: NoticeFlowCoordination) -> UIViewController
    func makeNoticeComposeViewController(mode: NoticeComposeViewModel.Mode,
                                         coordinator: NoticeFlowCoordination) -> UIViewController
    // 프로필 이미지 확대 — PostDetail의 PhotoBookViewController 패턴 재사용
    func makeProfileImageViewController(title: String?,
                                        imagePath: String?) -> UIViewController
}

final class NoticeSceneDIContainer: BaseContainer, NoticeSceneDependencies {

    private let entry: NoticeFlowEntry

    init(appNetworkService: AppNetworkService,
         commonFactory: ViewDependencies,
         userSession: UserSessionProvider,
         entry: NoticeFlowEntry) {
        self.entry = entry
        super.init(appNetworkService: appNetworkService,
                   commonFactory: commonFactory,
                   userSession: userSession)
    }

    func makeNoticeFlowCoordinator() -> NoticeFlowCoordinator {
        return .init(dependencies: self,
                     entry: entry,
                     navigationController: AppNaviViewController())
    }
}

// MARK: - Repo & UseCases
private extension NoticeSceneDIContainer {

    func makeNoticeRepo() -> NoticeRepo {
        return DefaultNoticeRepo(networkService: appNetworkService)
    }

    // 댓글 수정/삭제는 일반 CommentRepo의 endpoint(/comment/{commentId})를 그대로 사용 가능
    func makeCommentRepo() -> CommentRepo {
        return DefaultCommentRepo(networkService: appNetworkService)
    }

    func makeReportRepo() -> ReportRepo {
        return DefaultReportRepo(networkService: appNetworkService)
    }

    // MARK: Notice UseCases
    func makeFetchNoticeListUseCase(repo: NoticeRepo) -> FetchNoticeList {
        #if DEV
        return MockDataManager.resolve(FetchNoticeListUseCase(repo: repo) as FetchNoticeList,
                                       mock: MockFetchNoticeListUseCase())
        #else
        return FetchNoticeListUseCase(repo: repo)
        #endif
    }

    func makeTogglePinNoticeUseCase(repo: NoticeRepo) -> TogglePinNotice {
        #if DEV
        return MockDataManager.resolve(TogglePinNoticeUseCase(repo: repo) as TogglePinNotice,
                                       mock: MockTogglePinNoticeUseCase())
        #else
        return TogglePinNoticeUseCase(repo: repo)
        #endif
    }

    func makeCreateNoticeUseCase(repo: NoticeRepo) -> CreateNotice {
        #if DEV
        return MockDataManager.resolve(CreateNoticeUseCase(repo: repo) as CreateNotice,
                                       mock: MockCreateNoticeUseCase())
        #else
        return CreateNoticeUseCase(repo: repo)
        #endif
    }

    func makeUpdateNoticeUseCase(repo: NoticeRepo) -> UpdateNotice {
        #if DEV
        return MockDataManager.resolve(UpdateNoticeUseCase(repo: repo) as UpdateNotice,
                                       mock: MockUpdateNoticeUseCase())
        #else
        return UpdateNoticeUseCase(repo: repo)
        #endif
    }

    func makeDeleteNoticeUseCase(repo: NoticeRepo) -> DeleteNotice {
        #if DEV
        return MockDataManager.resolve(DeleteNoticeUseCase(repo: repo) as DeleteNotice,
                                       mock: MockDeleteNoticeUseCase())
        #else
        return DeleteNoticeUseCase(repo: repo)
        #endif
    }

    func makeFetchNoticeCommentListUseCase(repo: NoticeRepo) -> FetchNoticeCommentList {
        #if DEV
        return MockDataManager.resolve(FetchNoticeCommentListUseCase(repo: repo, session: userSession) as FetchNoticeCommentList,
                                       mock: MockFetchNoticeCommentListUseCase())
        #else
        return FetchNoticeCommentListUseCase(repo: repo, session: userSession)
        #endif
    }

    func makeCreateNoticeCommentUseCase(repo: NoticeRepo) -> CreateNoticeComment {
        #if DEV
        return MockDataManager.resolve(CreateNoticeCommentUseCase(repo: repo, session: userSession) as CreateNoticeComment,
                                       mock: MockCreateNoticeCommentUseCase())
        #else
        return CreateNoticeCommentUseCase(repo: repo, session: userSession)
        #endif
    }

    // MARK: Comment UseCases (수정/삭제는 일반 댓글 패턴 재사용)
    func makeEditCommentUseCase(repo: CommentRepo) -> EditComment {
        #if DEV
        return MockDataManager.resolve(EditCommentUseCase(repo: repo, session: userSession) as EditComment,
                                       mock: MockEditCommentUseCase())
        #else
        return EditCommentUseCase(repo: repo, session: userSession)
        #endif
    }

    func makeDeleteCommentUseCase(repo: CommentRepo) -> DeleteComment {
        #if DEV
        return MockDataManager.resolve(DeleteCommentUseCase(repo: repo) as DeleteComment,
                                       mock: MockDeleteCommentUseCase())
        #else
        return DeleteCommentUseCase(repo: repo)
        #endif
    }

    // MARK: Report UseCase
    func makeReportUseCase() -> ReportPost {
        let repo = makeReportRepo()
        #if DEV
        return MockDataManager.resolve(ReportPostUseCase(repo: repo) as ReportPost,
                                       mock: MockReportPostUseCase())
        #else
        return ReportPostUseCase(repo: repo)
        #endif
    }
}

// MARK: - View Factories (SwiftUI + UIHostingController)
extension NoticeSceneDIContainer {

    @MainActor
    func makeNoticeListViewController(meetId: Int,
                                      isCreator: Bool,
                                      coordinator: NoticeFlowCoordination) -> UIViewController {
        let repo = makeNoticeRepo()
        let viewModel = NoticeListViewModel(
            meetId: meetId,
            isCreator: isCreator,
            fetchListUseCase: makeFetchNoticeListUseCase(repo: repo),
            togglePinUseCase: makeTogglePinNoticeUseCase(repo: repo),
            coordinator: coordinator
        )
        return UIHostingController(rootView: NoticeListView(viewModel: viewModel))
    }

    @MainActor
    func makeNoticeDetailViewController(notice: Notice,
                                        isCreator: Bool,
                                        coordinator: NoticeFlowCoordination) -> UIViewController {
        let noticeRepo = makeNoticeRepo()
        let commentRepo = makeCommentRepo()
        let viewModel = NoticeDetailViewModel(
            notice: notice,
            isCreator: isCreator,
            fetchCommentsUseCase: makeFetchNoticeCommentListUseCase(repo: noticeRepo),
            createCommentUseCase: makeCreateNoticeCommentUseCase(repo: noticeRepo),
            editCommentUseCase: makeEditCommentUseCase(repo: commentRepo),
            deleteCommentUseCase: makeDeleteCommentUseCase(repo: commentRepo),
            reportUseCase: makeReportUseCase(),
            deleteNoticeUseCase: makeDeleteNoticeUseCase(repo: noticeRepo),
            coordinator: coordinator
        )
        return InteractivePopHostingController(rootView: NoticeDetailView(viewModel: viewModel))
    }

    @MainActor
    func makeNoticeComposeViewController(mode: NoticeComposeViewModel.Mode,
                                         coordinator: NoticeFlowCoordination) -> UIViewController {
        let repo = makeNoticeRepo()
        let viewModel = NoticeComposeViewModel(
            mode: mode,
            createUseCase: makeCreateNoticeUseCase(repo: repo),
            updateUseCase: makeUpdateNoticeUseCase(repo: repo),
            coordinator: coordinator
        )
        return InteractivePopHostingController(rootView: NoticeComposeView(viewModel: viewModel))
    }

    @MainActor
    func makeProfileImageViewController(title: String?,
                                        imagePath: String?) -> UIViewController {
        let imagePaths = [imagePath].compactMap { $0 }
        return commonViewFactory.makePhotoViewController(title: title,
                                                         imagePath: imagePaths,
                                                         defaultImageType: .user)
    }
}
