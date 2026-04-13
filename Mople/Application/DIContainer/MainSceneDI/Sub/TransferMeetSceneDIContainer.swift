//
//  TransferMeetSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 2/22/26.
//

import UIKit
import Domain
import SwiftUI

protocol TransferMeetSceneDependencies {
    func makeTransferMeetListView(coordinator: TransferMeetFlowCoordination) -> UIViewController
    func makeTransferMeetView(meet: Meet) -> UIViewController
}

final class TransferMeetSceneDIContainer: BaseContainer, TransferMeetSceneDependencies {
    
    // MARK: - Flow Coordinator
    func makeFlowCoordinator(onComplete: @escaping () -> Void) -> TransferMeetFlowCoordinator {
        let navController = AppNaviViewController(type: .sub)
        return TransferMeetFlowCoordinator(
            navigationController: navController,
            dependencies: self,
            onComplete: onComplete
        )
    }
    
    // MARK: - TransferMeetListView
    @MainActor
    func makeTransferMeetListView(coordinator: TransferMeetFlowCoordination) -> UIViewController {
        let viewModel = makeTransferMeetListViewModel(coordinator: coordinator)
        let view = TransferMeetListView(viewModel: viewModel)
        let hostingController = UIHostingController(rootView: view)
        return hostingController
    }
    
    @MainActor
    private func makeTransferMeetListViewModel(coordinator: TransferMeetFlowCoordination) -> TransferMeetListViewModel {
        return TransferMeetListViewModel(
            fetchMyHostMeetsUseCase: makeFetchMyHostMeetsUseCase(),
            deleteAccountUseCase: makeDeleteAccountUseCase(),
            coordinator: coordinator
        )
    }
    
    // MARK: - TransferMeetView
    @MainActor
    func makeTransferMeetView(meet: Meet) -> UIViewController {
        let viewModel = makeTransferMeetViewModel(meet: meet)
        let view = TransferMeetView(viewModel: viewModel)
        let hostingController = EdgePopHostingController(rootView: view)
        return hostingController
    }
    
    @MainActor
    private func makeTransferMeetViewModel(meet: Meet) -> TransferMeetViewModel {
        return TransferMeetViewModel(
            meet: meet,
            fetchMemberListUseCase: makeFetchMemberListUseCase(),
            transferUseCase: makeTransferMeetUseCase()
        )
    }
    
    // MARK: - UseCases
    private func makeFetchMyHostMeetsUseCase() -> FetchMyHostMeets {
        #if DEV
        return MockDataManager.resolve(FetchMyHostMeetsUseCase(repo: makeMeetRepo()) as FetchMyHostMeets, mock: MockFetchMyHostMeetsUseCase())
        #else
        return FetchMyHostMeetsUseCase(repo: makeMeetRepo())
        #endif
    }

    private func makeFetchMemberListUseCase() -> FetchMemberList {
        let memberRepo = DefaultMemberRepo(networkService: appNetworkService)
        #if DEV
        return MockDataManager.resolve(FetchMemberUseCase(memberListRepo: memberRepo) as FetchMemberList, mock: MockFetchMemberUseCase())
        #else
        return FetchMemberUseCase(memberListRepo: memberRepo)
        #endif
    }

    private func makeTransferMeetUseCase() -> TransferMeet {
        #if DEV
        return MockDataManager.resolve(TransferMeetUseCase(repo: makeMeetRepo()) as TransferMeet, mock: MockTransferMeetUseCase())
        #else
        return TransferMeetUseCase(repo: makeMeetRepo())
        #endif
    }
    
    private func makeMeetRepo() -> MeetRepo {
        return DefaultMeetRepo(networkService: appNetworkService)
    }

  
    private func makeDeleteAccountUseCase() -> DeleteAccount {
        let authRepo = DefaultAuthenticationRepo(networkService: appNetworkService)
        #if DEV
        return MockDataManager.resolve(DeleteAccountUseCase(repo: authRepo) as DeleteAccount, mock: MockDeleteAccountUseCase())
        #else
        return DeleteAccountUseCase(repo: authRepo)
        #endif
    }
}
// MARK: - Edge Pop 지원 UIHostingController
final class EdgePopHostingController<Content: View>: UIHostingController<Content> {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
}

