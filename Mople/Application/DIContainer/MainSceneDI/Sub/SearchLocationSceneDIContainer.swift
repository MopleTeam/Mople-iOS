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
    func makePlaceSelectViewController(with place: PlaceInfo) -> PlaceSelectViewController
}

final class SearchLocationSceneDIContainer: SearchPlaceSceneDependencies {

    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    private var commonReactor: SearchPlaceViewReactor?
    private weak var delegate: SearchPlaceDelegate?
    
    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory,
         delegate: SearchPlaceDelegate) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
        self.delegate = delegate
    }
    
    func makeSearchLocationFlowCoordinator() -> BaseCoordinator {
        return SearchPlaceFlowCoordinator(navigationController: AppNaviViewController(),
                                          dependencies: self)
    }
}

// MARK: - View
extension SearchLocationSceneDIContainer {
    func makeSearchLocationViewController(coordinator: SearchPlaceCoordination
    ) -> SearchPlaceViewController {
        makeCommonReactor(coordinator: coordinator)
        return SearchPlaceViewController(reactor: commonReactor)
    }
    
    func makeSearchResultViewController() -> SearchResultViewController {
        return .init(reactor: commonReactor)
    }
    
    func makePlaceSelectViewController(with place: PlaceInfo) -> PlaceSelectViewController {
        return PlaceSelectViewController(reactor: commonReactor,
                                         place: place)
    }
}

// MARK: - Common Reactor
extension SearchLocationSceneDIContainer {
    private func makeCommonReactor(coordinator: SearchPlaceCoordination) {
        guard let delegate else { return }
        commonReactor = .init(searchLocationUseCase: makeSearchLocationUseCase(),
                              locationService: DefaultLocationService(),
                              queryStorage: DefaultSearchedPlaceStorage(),
                              coordinator: coordinator,
                              delegate: delegate)
    }
    
    private func makeSearchLocationUseCase() -> SearchPlace {
        return SearchPlaceUseCase(searchPlaceRepo: makeSearchLocationRepo())
    }
    
    private func makeSearchLocationRepo() -> SearchPlaceRepo {
        return DefaultSearchPlaceRepo(networkService: appNetworkService)
    }
}
