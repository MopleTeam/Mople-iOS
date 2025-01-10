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

// MARK: - View
extension SearchLocationSceneDIContainer {
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

// MARK: - Common Reactor
extension SearchLocationSceneDIContainer {
    private func makeCommonReactor(coordinator: SearchPlaceCoordination) {
        commonReactor = .init(searchLocationUseCase: makeSearchLocationUseCase(),
                              locationService: makeLocationService(),
                              queryStorage: DefaultSearchedPlaceStorage(),
                              coordinator: coordinator)
    }
    
    private func makeSearchLocationUseCase() -> SearchLoaction {
        return SearchLoactionUseCase(searchLocationRepo: makeSearchLocationRepo())
    }
    
    private func makeSearchLocationRepo() -> SearchLocationRepo {
        return DefaultSearchLocationRepo(networkService: appNetworkService)
    }
    
    private func makeLocationService() -> LocationService {
        return DefaultLocationService()
    }
}
