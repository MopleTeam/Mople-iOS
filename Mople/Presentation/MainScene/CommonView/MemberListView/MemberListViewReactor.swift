//
//  MemberListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import ReactorKit

protocol MemberListViewCoordination: NavigationCloseable { }

enum MemberListType {
    case meet(id: Int?)
    case plan(id: Int?)
    case review(id: Int?)
}

enum MemberListError: Error {
    case nonId
}

final class MemberListViewReactor: Reactor {
    
    enum Action {
        case fetchPlanMemeber
        case endFlow
    }
    
    enum Mutation {
        case updateMember([MemberInfo])
        case updateLoadingState(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var members: [MemberInfo] = []
        @Pulse var isLoading: Bool = false
    }
    
    var initialState: State = State()
    
    private let fetchPlanMemberUseCase: FetchMemberList
    private let type: MemberListType
    private weak var coordinator: MemberListViewCoordination?
    
    init(type: MemberListType,
         fetchPlanMemberUseCase: FetchMemberList,
         coordinator: MemberListViewCoordination) {
        self.fetchPlanMemberUseCase = fetchPlanMemberUseCase
        self.coordinator = coordinator
        self.type = type
        handleViewType()
    }
    
    private func handleViewType() {
        switch type {
        case .meet(_):
            break
        case let .plan(id):
            action.onNext(.fetchPlanMemeber)
        case .review(_):
            break
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchPlanMemeber:
            return fetchPlanMember()
        case .endFlow:
            coordinator?.pop()
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
        }
        
        return newState
    }
}

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

extension MemberListViewReactor {
    private func fetchPlanMember() -> Observable<Mutation> {
        let fetchPlanMember = fetchPlanMemberUseCase.execute(type: type)
            .asObservable()
            .map { Mutation.updateMember($0.membsers) }
        
        return fetchWithLoading(fetchPlanMember)
    }
}

extension MemberListViewReactor {
    private func fetchWithLoading(_ task: Observable<Mutation>) -> Observable<Mutation> {
        let startLoad = Observable.just(Mutation.updateLoadingState(true))
        
        let endLoad = Observable.just(Mutation.updateLoadingState(false))
        
        return Observable.concat([startLoad,
                                  task,
                                  endLoad])
    }
}

