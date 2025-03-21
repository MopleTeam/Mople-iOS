//
//  PlaceDetailVIewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/3/25.
//

import ReactorKit

protocol PlaceDetailCoordination: AnyObject {
    func pop()
}

final class PlaceDetailViewReactor: Reactor {
    
    enum Action {
        case setPlace(PlaceInfo)
        case endProcess
    }
    
    enum Mutation {
        case updatePlaceInfo(PlaceInfo?)
        case updateLoadingState(Bool)
    }
    
    struct State {
        @Pulse var placeInfo: PlaceInfo?
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let locationService: LocationService
    private weak var coordinator: PlaceDetailCoordination?
    
    init(place: PlaceInfo,
         locationService: LocationService,
         coordinator: PlaceDetailCoordination) {
        self.locationService = locationService
        self.coordinator = coordinator
        action.onNext(.setPlace(place))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setPlace(placeInfo):
            return updatePlaceInfo(placeInfo)
        case .endProcess:
            coordinator?.pop()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updatePlaceInfo(placeInfo):
            newState.placeInfo = placeInfo
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        }
        
        return newState
    }
}

extension PlaceDetailViewReactor {
    private func updatePlaceInfo(_ placeInfo: PlaceInfo) -> Observable<Mutation> {
        let loadingEnd = Observable.just(Mutation.updateLoadingState(false))
            .filter { [weak self] _ in self?.currentState.isLoading == true }
        
        let location = locationService.updateLocation()
            .map({
                var newPlaceInfo = placeInfo
                newPlaceInfo.updateDistance(userLocation: $0)
                return newPlaceInfo
            })
            .map { Mutation.updatePlaceInfo($0) }
            .concat(loadingEnd)
            .share(replay: 1)
        
        let loading = Observable.just(Mutation.updateLoadingState(true))
            .delay(.milliseconds(500), scheduler: MainScheduler.instance)
            .take(until: location)

        return .merge([location, loading])
    }
}

