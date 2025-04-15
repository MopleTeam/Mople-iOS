//
//  PlaceDetailVIewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/3/25.
//

import ReactorKit

protocol PlaceDetailCoordination: NavigationCloseable { }

final class PlaceDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case setPlace
        case endProcess
    }
    
    enum Mutation {
        case updatePlaceInfo(PlaceInfo?)
        case updateLoadingState(Bool)
        case catchError(Error)
    }
    
    struct State {
        @Pulse var placeInfo: PlaceInfo?
        @Pulse var isLoading: Bool = false
        @Pulse var error: Error?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var place: PlaceInfo
    
    // MARK: - Location
    private let locationService: LocationService
    
    // MARK: - Coordinator
    private weak var coordinator: PlaceDetailCoordination?
    
    // MARK: - LifeCycle
    init(place: PlaceInfo,
         locationService: LocationService,
         coordinator: PlaceDetailCoordination) {
        self.place = place
        self.locationService = locationService
        self.coordinator = coordinator
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Intial Setup
    private func initialAction() {
        action.onNext(.setPlace)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setPlace:
            return updatePlaceInfo()
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
        case .catchError:
            break
        }
        
        return newState
    }
}

// MARK: - User Location Update
extension PlaceDetailViewReactor {
    private func updatePlaceInfo() -> Observable<Mutation> {
        let location = locationService.updateLocation()
            .flatMap({ [weak self] location -> Observable<Mutation> in
                guard let self else { return .empty() }
                place.updateDistance(userLocation: location)
                return .just(.updatePlaceInfo(place))
            })

        return requestWithLoading(task: location)
    }
}

// MARK: - Loading & Error
extension PlaceDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        return .catchError(error)
    }
}
