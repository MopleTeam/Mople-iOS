//
//  MemberListViewReactor.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//
import UIKit
import ReactorKit

protocol MemberListViewCoordination: NavigationCloseable {
    func presentPhotoView(imagePath: String?)
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
        enum Flow {
            case showUserImage(imagePath: String?)
            case endFlow
            case endView
        }
        
        case fetchPlanMemeber
        case invite
        case flow(Flow)
    }
    
    enum Mutation {
        case updateMember([MembersSectionModel])
        case updateInviteUrl(String)
        case updateLoadingState(Bool)
        case catchError(MemberListError)
    }
    
    struct State {
        @Pulse var members: [MembersSectionModel] = []
        @Pulse var inviteUrl: String?
        @Pulse var isLoading: Bool = false
        @Pulse var error: MemberListError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let type: MemberListType
    private var isLoading = false
    
    // MARK: - UseCase
    private let fetchMemberUseCase: FetchMemberList
    private let inviteMeetUseCase: InviteMeet
    
    // MARK: - Coordinator
    private weak var coordinator: MemberListViewCoordination?
    
    // MARK: - LifeCycle
    init(type: MemberListType,
         fetchMemberUseCase: FetchMemberList,
         inviteMeetUseCase: InviteMeet,
         coordinator: MemberListViewCoordination) {
        self.fetchMemberUseCase = fetchMemberUseCase
        self.inviteMeetUseCase = inviteMeetUseCase
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
        case .invite:
            return requestInviteUrl()
        case let .flow(action):
            return handleFlowAction(action)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateMember(members):
            newState.members = members
        case let .updateInviteUrl(url):
            newState.inviteUrl = url
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Action Handling
extension MemberListViewReactor {
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case let .showUserImage(imagePath):
            coordinator?.presentPhotoView(imagePath: imagePath)
        case .endFlow:
            coordinator?.endFlow()
        case .endView:
            coordinator?.pop()
        }
        return .empty()
    }
}

// MARK: - Data Request
extension MemberListViewReactor {
    private func fetchPlanMember() -> Observable<Mutation> {
        let fetchMember = fetchMemberUseCase.execute(type: type)
            .map({ [weak self] memberList -> [MemberInfo] in
                guard let self else { return [] }
                return sortMembersByPosition(memberList.membsers)
            })
            .map { [MembersSectionModel(items: $0)] }
            .map { Mutation.updateMember($0) }
        
        return requestWithLoading(task: fetchMember)
    }
    
    private func makeResponseType() -> ResponseType? {
        switch type {
        case let .meet(id): return id.map { .meet(id: $0) }
        case let .plan(id): return id.map { .plan(id: $0) }
        case let .review(id): return id.map { .review(id: $0) }
        }
    }
    
    private func requestInviteUrl() -> Observable<Mutation> {
        guard case .meet(let id) = type,
              let id,
              !isLoading else { return .empty() }
        
        isLoading = true
        let inviteMeet = inviteMeetUseCase.execute(id: id)
            .map { Mutation.updateInviteUrl($0) }
        
        return requestWithLoading(task: inviteMeet)
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
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
