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
    func makeDetailLocationViewController() -> PlaceSelectViewController
}

final class SearchLocationSceneDIContainer: SearchPlaceSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    private var commonReactor: SearchPlaceViewReactor?
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
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
    
    func makeDetailLocationViewController() -> PlaceSelectViewController {
        return PlaceSelectViewController(reactor: commonReactor)
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
