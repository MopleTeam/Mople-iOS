//
//  MemberListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import ReactorKit

protocol MemberListCoordination: AnyObject {
    func pop()
}

enum MemberListViewType {
    case meetMember(id: Int)
    case planMember(id: Int)
    case reviewMember(id: Int)
}

final class MemberListViewReactor: Reactor {
    
    enum Action {
        case fetchPlanMemeber(id: Int)
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
    
    private let fetchPlanMemberUseCase: FetchPlanMember
    private weak var coordinator: MemberListCoordination?
    
    init(type: MemberListViewType,
         fetchPlanMemberUseCase: FetchPlanMember,
         coordinator: MemberListCoordination) {
        self.fetchPlanMemberUseCase = fetchPlanMemberUseCase
        self.coordinator = coordinator
        handleViewType(type)
    }
    
    private func handleViewType(_ type: MemberListViewType) {
        switch type {
        case .meetMember(_):
            break
        case let .planMember(id):
            action.onNext(.fetchPlanMemeber(id: id))
        case .reviewMember(_):
            break
        }
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .fetchPlanMemeber(id):
            return fetchPlanMember(id: id)
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
    private func fetchPlanMember(id: Int) -> Observable<Mutation> {
        let fetchPlanMember = fetchPlanMemberUseCase.execute(planId: id)
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

