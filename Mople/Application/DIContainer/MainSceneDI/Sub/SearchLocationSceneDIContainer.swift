//
//  SearchLocationSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 12/24/24.
//

import UIKit

protocol SearchPlaceSceneDependencies {
    func makeSearchLocationViewController(coordinator: SearchPlaceCoordination) -> SearchPlaceViewController
    func makeSearchResultViewController() -> SearchResultViewController
    func makeDetailLocationViewController(place: PlaceInfo) -> DetailPlaceViewController
}

final class SearchLocationSceneDIContainer: SearchPlaceSceneDependencies {

    private let appNetworkService: AppNetworkService
    private var commonReactor: SearchPlaceViewReactor?
    
    init(appNetworkService: AppNetworkService) {
        self.appNetworkService = appNetworkService
    }
    
    func makeSearchLocationFlowCoordinator() -> BaseCoordinator {
        return SearchPlaceFlowCoordinator(navigationController: AppNaviViewController(),
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
    
    private func makeSearchLocationUseCase() -> SearchPlace {
        return SearchPlaceUseCase(searchPlaceRepo: makeSearchLocationRepo())
    }
    
    private func makeSearchLocationRepo() -> SearchPlaceRepo {
        return DefaultSearchPlaceRepo(networkService: appNetworkService)
    }
    
    private func makeLocationService() -> LocationService {
        return DefaultLocationService()
    }
}
