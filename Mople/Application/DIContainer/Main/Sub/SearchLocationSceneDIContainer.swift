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
    func makeSearchLocationViewController(coordinator: SearchPlaceCoordination) -> SearchPlaceViewController
    func makeSearchResultViewController() -> SearchResultViewController
    func makeDetailLocationViewController(place: PlaceInfo) -> DetailPlaceViewController
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
    private func makeCommonReactor(coordinator: SearchPlaceCoordination) {
        commonReactor = .init(searchLocationUseCase: SearchLoactionUseCaseMock(),
                              queryStorage: DefaultSearchedPlaceStorage(),
                              coordinator: coordinator)
    }
    
    func makeSearchLocationViewController(coordinator: SearchPlaceCoordination) -> SearchPlaceViewController {
        makeCommonReactor(coordinator: coordinator)
        return SearchPlaceViewController(reactor: commonReactor)
    }
    
    func makeSearchResultViewController() -> SearchResultViewController {
        return .init(reactor: commonReactor)
    }
    
    func makeDetailLocationViewController(place: PlaceInfo) -> DetailPlaceViewController {
        return DetailPlaceViewController(reactor: commonReactor, place: place)
    }
}
