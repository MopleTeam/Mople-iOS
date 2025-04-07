//
//  SearchLocationViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/25/24.
//

import Foundation
import ReactorKit

protocol SearchPlaceDelegate: AnyObject {
    func selectedPlace(with place: PlaceInfo)
}

final class SearchPlaceViewReactor: Reactor, LifeCycleLoggable {
    
    struct PlaceSearchResult {
        let places: [PlaceInfo]
        let isCached: Bool
    }
    
    enum Action {
        case updateUserLocation
        case fetchCahcedPlace
        case searchPlace(query: String)
        case selectedPlace(index: Int)
        case deletePlace(index: Int)
        case endProcess
        case completed(place: PlaceInfo)
    }
    
    enum Mutation {
        case setUserLocation(_ location: Location?)
        case setPlace(_ result: PlaceSearchResult)
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var searchResult: PlaceSearchResult?
        @Pulse var userLocation: Location?
        @Pulse var isLoading: Bool = false
        @Pulse var error: Error?
    }
    
    var initialState: State = State()
    
    private let searchUseCase: SearchPlace
    private let locationService: LocationService
    private let queryStorage: SearchedPlaceStorage
    private weak var coordinator: SearchPlaceCoordination?
    private weak var delegate: SearchPlaceDelegate?
    
    init(searchLocationUseCase: SearchPlace,
         locationService: LocationService,
         queryStorage: SearchedPlaceStorage,
         coordinator: SearchPlaceCoordination,
         delegate: SearchPlaceDelegate) {
        self.searchUseCase = searchLocationUseCase
        self.locationService = locationService
        self.queryStorage = queryStorage
        self.coordinator = coordinator
        self.delegate = delegate
        logLifeCycle()
        initalAction()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .updateUserLocation:
            return updateUserLocation()
        case .fetchCahcedPlace:
            return self.fetchCahcedPlace()
        case let .searchPlace(query):
            return self.searchPlace(query: query)
        case let .selectedPlace(index):
            return self.updateSelectedPlace(index: index)
        case let .deletePlace(index):
            return self.deleteHistory(index: index)
        case .endProcess:
            self.coordinator?.endProcess()
            return .empty()
        case let .completed(place):
            delegate?.selectedPlace(with: place)
            coordinator?.completed()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .setPlace(result):
            newState.searchResult = result
        case let .catchError(err):
            newState.error = err
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .setUserLocation(location):
            newState.userLocation = location
        }
        
        return newState
    }
    
    private func initalAction() {
        action.onNext(.updateUserLocation)
        action.onNext(.fetchCahcedPlace)
    }
}

extension SearchPlaceViewReactor {
    private func fetchCahcedPlace() -> Observable<Mutation> {
        let places = queryStorage.readPlaces()
        self.updateHistoryVisibility(result: places)
        return .just(Mutation.setPlace(.init(places: places, isCached: true)))
    }
    
    private func updateUserLocation() -> Observable<Mutation> {
        let location = locationService.updateLocation()
            .map { Mutation.setUserLocation($0) }

        return requestWithLoading(task: location,
                                  defferredLoadingDelay: .seconds(0))
    }
    
    private func searchPlace(query: String) -> Observable<Mutation> {
        
        let userLocation = currentState.userLocation

        let requestSearch = searchUseCase.execute(query: query,
                                                  x: userLocation?.longitude,
                                                  y: userLocation?.latitude)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .filter({ [weak self] response in
                let isEmpty = response.result.isEmpty
                self?.updateSearchResultVisibility(result: response.result)
                return !isEmpty
            })
            .map { Mutation.setPlace(.init(places: $0.result, isCached: false)) }
        
        return requestWithLoading(task: requestSearch)
    }
        
    private func updateSelectedPlace(index: Int) -> Observable<Mutation> {
        
        guard let selectedPlace = self.selectedPlace(index: index) else {
            return .empty()
        }
        coordinator?.showDetailPlaceView(with: selectedPlace)
        queryStorage.addPlace(selectedPlace)
        
        if currentState.searchResult?.isCached == true {
            return Observable.just(())
                .delay(.milliseconds(300), scheduler: MainScheduler.instance)
                .flatMap { [weak self] _ -> Observable<Mutation> in
                    guard let self else { return .empty() }
                    return self.fetchCahcedPlace()
                }
        } else {
            return .empty()
        }
    }
    
    private func selectedPlace(index: Int) -> PlaceInfo? {
        guard let result = currentState.searchResult,
              var selectedPlace = result.places[safe: index] else { return nil }
        selectedPlace.updateDistance(userLocation: currentState.userLocation)
        return selectedPlace
    }
    
    private func deleteHistory(index: Int) -> Observable<Mutation>  {
        guard let result = currentState.searchResult,
              result.isCached,
              result.places.count > index,
              let deletedHisotry = result.places[safe: index] else { return .empty() }
        
        queryStorage.deletePlace(deletedHisotry)
        return fetchCahcedPlace()
    }
}

// MARK: - Flow Update
extension SearchPlaceViewReactor {
    
    /// 캐시데이터가 있으면 검색결과 창 표시, 없다면 기본 화면 표시 (기본화면 startView)
    /// - updateEmptyViewVisibility false
    ///     - 검색어를 모두 지운 경우 히스토리 or 기본 화면 표시
    ///     - 검색결과가 없을 경우 emptyView가 표시되고 있음으로 false
    private func updateHistoryVisibility(result: [PlaceInfo]) {
        self.coordinator?.updateEmptyViewVisibility(shouldShow: false)
        self.coordinator?.updateSearchResultViewVisibility(shouldShow: !result.isEmpty)
    }
    
    /// 검색결과 유무에 따라서 뷰 표시
    /// - 검색결과 유무
    ///     - 데이터 O : 결과창 표시
    ///     - 데이터 X : empty view 표시
    private func updateSearchResultVisibility(result: [PlaceInfo]) {
        self.coordinator?.updateEmptyViewVisibility(shouldShow: result.isEmpty)
        self.coordinator?.updateSearchResultViewVisibility(shouldShow: !result.isEmpty)
    }
}

// MARK: - 로딩
extension SearchPlaceViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}
