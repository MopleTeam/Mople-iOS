//
//  SearchLocationSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 12/24/24.
//

import UIKit

protocol SearchLocationSceneContainer {
    func makeSearchLocationFlowCoordinator(navigationController: UINavigationController) -> BaseCoordinator
}

protocol SearchPlaceSceneDependencies {
    func makeSearchLocationViewController(flow: SearchPlaceFlowAction) -> SearchPlaceViewController
    func makeSearchResultViewController() -> SearchResultViewController
    func makeDetailLocationViewController() -> UIViewController
}

final class SearchLocationSceneDIContainer: SearchPlaceSceneDependencies & SearchLocationSceneContainer {

    private let appNetworkService: AppNetworkService
    private var commonReactor: SearchPlaceReactor?
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeSearchLocationFlowCoordinator(navigationController: UINavigationController) -> BaseCoordinator {
        return SearchPlaceFlowCoordinator(navigationController: navigationController,
                                              dependencies: self)
    }
}

extension SearchLocationSceneDIContainer {
    private func makeCommonReactor(flow: SearchPlaceFlowAction) {
        commonReactor = .init(searchLocationUseCase: SearchLoactionUseCaseMock(),
                              queryStorage: DefaultSearchedPlaceStorage(),
                              flow: flow)
    }
    
    func makeSearchLocationViewController(flow: SearchPlaceFlowAction) -> SearchPlaceViewController {
        makeCommonReactor(flow: flow)
        return SearchPlaceViewController(reactor: commonReactor)
    }
    
    func makeSearchResultViewController() -> SearchResultViewController {
        return .init(reactor: commonReactor)
    }
    
    func makeDetailLocationViewController() -> UIViewController {
        return UIViewController()
    }
}
