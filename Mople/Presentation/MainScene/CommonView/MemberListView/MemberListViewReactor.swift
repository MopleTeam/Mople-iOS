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
        
        case fetchPage
        case fetchNextPage
        case invite
        case flow(Flow)
    }
    
    enum Mutation {
        case fetchedPage([MemberInfo])
        case fetchedInviteUrl(String)
        case updateLoadingState(Bool)
        case catchError(MemberListError)
    }
    
    struct State {
        @Pulse var members: [MemberInfo] = []
        @Pulse var inviteUrl: String?
        @Pulse var isLoading: Bool = false
        @Pulse var error: MemberListError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let type: MemberListType
    private var isLoading = false
    private var page: PageInfo?
    
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
        action.onNext(.fetchPage)
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        guard shouldAction(action) else { return .empty() }
        switch action {
        case .fetchPage:
            return fetchPlanMember()
        case .fetchNextPage:
            return fetchNextPage()
        case .invite:
            return requestInviteUrl()
        case let .flow(action):
            return handleFlowAction(action)
        }
    }
    
    private func shouldAction(_ action: Action) -> Bool {
        switch action {
        case .flow:
            return true
        default:
            return !isLoading
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .fetchedPage(members):
            newState.members.append(contentsOf: members)
        case let .fetchedInviteUrl(url):
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
    /// 멤버 목록을 페이지 단위로 불러온다
    private func fetchPlanMember(cursor: String? = nil) -> Observable<Mutation> {
        isLoading = true
        let cursor = page?.nextCursor
        let type = self.type
        let fetchMember = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    let result = try await self?.fetchMemberUseCase.execute(type: type, cursor: cursor)
                    if let result {
                        self?.page = result.info
                        observer.onNext(.fetchedPage(result.content))
                    }
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: fetchMember)
    }
    
    private func fetchNextPage(cursor: String? = nil) -> Observable<Mutation> {
        guard let cursor = page?.nextCursor else { return .empty() }
        return fetchPlanMember(cursor: cursor)
    }
    
    /// 모임 초대 URL을 요청한다
    private func requestInviteUrl() -> Observable<Mutation> {
        guard case .meet(let id) = type,
              let id else { return .empty() }

        isLoading = true
        let inviteMeet = Observable<Mutation>.create { [weak self] observer in
            let task = Task { [weak self] in
                do {
                    guard let url = try await self?.inviteMeetUseCase.execute(id: id) else {
                        observer.onCompleted()
                        return
                    }
                    observer.onNext(.fetchedInviteUrl(url))
                    observer.onCompleted()
                } catch {
                    observer.onError(error)
                }
            }
            return Disposables.create { task.cancel() }
        }

        return requestWithLoading(task: inviteMeet)
    }
}

// MARK: - Loading & Error
extension MemberListViewReactor: LoadingReactor {
    func updateLoadingState(isLoad: Bool) {
        isLoading = isLoad
    }
    
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
    
    private func makeResponseType() -> ResponseType? {
        switch type {
        case let .meet(id): return id.map { .meet(id: $0) }
        case let .plan(id): return id.map { .plan(id: $0) }
        case let .review(id): return id.map { .review(id: $0) }
        }
    }
}
