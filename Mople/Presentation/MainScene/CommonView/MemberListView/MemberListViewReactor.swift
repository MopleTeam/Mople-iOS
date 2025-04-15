//
//  MemberListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//
import UIKit
import ReactorKit

protocol MemberListViewCoordination: NavigationCloseable {
    func endFlow()
}

enum MemberListType {
    case meet(id: Int?)
    case plan(id: Int?)
    case review(id: Int?)
}

enum MemberListError: Error {
    case noResponse(ResponseError)
    case unknown(Error)
}

final class MemberListViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchPlanMemeber
        case endFlow
        case endView
    }
    
    enum Mutation {
        case updateMember([MemberInfo])
        case updateLoadingState(Bool)
        case catchError(MemberListError)
    }
    
    struct State {
        @Pulse var members: [MemberInfo] = []
        @Pulse var isLoading: Bool = false
        @Pulse var error: MemberListError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let type: MemberListType
    
    // MARK: - UseCase
    private let fetchMemberUseCase: FetchMemberList
    
    // MARK: - Coordinator
    private weak var coordinator: MemberListViewCoordination?
    
    // MARK: - LifeCycle
    init(type: MemberListType,
         fetchMemberUseCase: FetchMemberList,
         coordinator: MemberListViewCoordination) {
        self.fetchMemberUseCase = fetchMemberUseCase
        self.coordinator = coordinator
        self.type = type
        initialAction()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Initial Setup
    private func initialAction() {
        action.onNext(.fetchPlanMemeber)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchPlanMemeber:
            return fetchPlanMember()
        case .endView:
            coordinator?.pop()
            return .empty()
        case .endFlow:
            coordinator?.endFlow()
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateMember(members):
            newState.members = sortMembersByPosition(members)
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Data Request
extension MemberListViewReactor {
    private func fetchPlanMember() -> Observable<Mutation> {
        let fetchMember = fetchMemberUseCase.execute(type: type)
            .asObservable()
            .map { Mutation.updateMember($0.membsers) }
        
        return requestWithLoading(task: fetchMember)
    }
    
    private func makeResponseType() -> ResponseType? {
        switch type {
        case let .meet(id): return id.map { .meet(id: $0) }
        case let .plan(id): return id.map { .plan(id: $0) }
        case let .review(id): return id.map { .review(id: $0) }
        }
    }
}

// MARK: - Helper
extension MemberListViewReactor {
    private func sortMembersByPosition(_ members: [MemberInfo]) -> [MemberInfo] {
        let hostMember = members.filter {
            $0.position == .host || $0.position == .owner
        }
        
        let otherMembers = members.filter {
            $0.position == .member
        }.sorted(by: <)
        
        return hostMember + otherMembers
    }
}

// MARK: - Loading & Error
extension MemberListViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = handleDataRequestError(err: dataError) else {
            return .catchError(.unknown(error))
        }
        return .catchError(.noResponse(responseError))
    }
    
    private func handleDataRequestError(err: DataRequestError) -> ResponseError? {
        guard let responseType = makeResponseType() else { return nil }
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: responseType)
    }
}
