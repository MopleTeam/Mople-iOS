//
//  DetailGroupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import ReactorKit

protocol MeetDetailDelegate: AnyObject, ChildLoadingDelegate {
    func selectedPlan(id: Int, type: PlanDetailType)
}

enum MeetDetailError: Error {
    case noResponse(ResponseError)
    case midnight(DateTransitionError)
    case unknown(Error)
}

final class MeetDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Flow {
            case switchPage(isFuture: Bool)
            case pushMeetSetupView
            case endFlow
        }

        enum Loading {
            case planLoading(Bool)
            case reviewLoading(Bool)
        }
        
        case loading(Loading)
        case editMeet(MeetPayload)
        case resetList
        case fetchMeetInfo
        case flow(Flow)
        case catchError(MeetDetailError)
    }
    
    enum Mutation {
        case setMeetInfo(meet: Meet)
        case updateMeetInfoLoading(Bool)
        case updatePlanListLoading(Bool)
        case updateReviewListLoading(Bool)
        case catchError(MeetDetailError)
    }
    
    struct State {
        @Pulse var meet: Meet?
        @Pulse var message: String?
        @Pulse var meetInfoLoaded: Bool = false
        @Pulse var futurePlanLoaded: Bool = false
        @Pulse var pastPlanLoaded: Bool = false
        @Pulse var error: MeetDetailError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private let meetId: Int
    
    // MARK: - UseCase
    private let fetchMeetUseCase: FetchMeetDetail
    
    // MARK: - Coordinator
    private weak var coordinator: MeetDetailCoordination?
    
    // MARK: - Commands
    public weak var planListCommands: MeetPlanListCommands?
    public weak var reviewListCommands: MeetReviewListCommands?
    
    // MARK: - LifeCycle
    init(fetchMeetUseCase: FetchMeetDetail,
         coordinator: MeetDetailCoordination,
         meetID: Int) {
        self.fetchMeetUseCase = fetchMeetUseCase
        self.coordinator = coordinator
        self.meetId = meetID
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchMeetInfo:
            return self.fetchMeetInfo()
        case let .editMeet(payload):
            return handleMeetPayload(with: payload)
        case .resetList:
            return resetPost()
        case let .loading(action):
            return handleChildLoading(action)
        case let .flow(action):
            return handleFlowAction(action)
        case let .catchError(err):
            return .just(.catchError(err))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .setMeetInfo(meet):
            newState.meet = meet
        case let .updateMeetInfoLoading(isLoading):
            newState.meetInfoLoaded = isLoading
        case let .updatePlanListLoading(isLoading):
            newState.futurePlanLoaded = isLoading
        case let .updateReviewListLoading(isLoading):
            newState.pastPlanLoaded = isLoading
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Data Request
extension MeetDetailViewReactor {
    private func fetchMeetInfo() -> Observable<Mutation> {
        
        let fetchMeet = fetchMeetUseCase.execute(meetId: meetId)
            .asObservable()
            .map { [weak self] in
                self?.fetchPost()
                return Mutation.setMeetInfo(meet: $0)
            }
        
        return requestWithLoading(task: fetchMeet)
    }
}

// MARK: - Coordinator
extension MeetDetailViewReactor {
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case let .switchPage(isFuture):
            coordinator?.swicthPlanListPage(isFuture: isFuture)
        case .pushMeetSetupView:
            guard let meet = currentState.meet else { return .empty() }
            coordinator?.pushMeetSetupView(meet: meet)
        case .endFlow:
            coordinator?.endFlow()
        }
        
        return .empty()
    }
}

// MARK: - Notify
extension MeetDetailViewReactor {
    /// 미팅 수정 알림 수신
    private func handleMeetPayload(with payload: MeetPayload) -> Observable<Mutation> {
        guard case .updated(let meet) = payload else { return .empty() }
        return .just(.setMeetInfo(meet: meet))
    }
    
    private func resetPost() -> Observable<Mutation> {
        fetchPost()
        return .empty()
    }
}

// MARK: - Commands
extension MeetDetailViewReactor {
    private func fetchPost() {
        planListCommands?.fetchPlan()
        reviewListCommands?.fetchReview()
    }
}

// MARK: - Delegate
extension MeetDetailViewReactor: MeetDetailDelegate {
    
    func selectedPlan(id: Int, type: PlanDetailType) {
        coordinator?.pushPlanDetailView(postId: id, type: type)
    }
    
    func updateLoadingState(_ isLoading: Bool, index: Int) {
        switch index {
        case 0:
            action.onNext(.loading(.planLoading(isLoading)))
        case 1:
            action.onNext(.loading(.reviewLoading(isLoading)))
        default:
            break
        }
    }

    func catchError(_ error: Error, index: Int) {
        switch error {
        case let error as DateTransitionError:
            action.onNext(.catchError(.midnight(error)))
        case let error as ResponseError:
            action.onNext(.catchError(.noResponse(error)))
        default:
            return
        }
    }
}

// MARK: - Child Loading
extension MeetDetailViewReactor {
    private func handleChildLoading(_ action: Action.Loading) -> Observable<Mutation> {
        switch action {
        case let .planLoading(isLoad):
            return .just(.updatePlanListLoading(isLoad))
        case let .reviewLoading(isLoad):
            return .just(.updateReviewListLoading(isLoad))
        }
    }
}

// MARK: - Loading & Error
extension MeetDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateMeetInfoLoading(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = handleDataRequestError(err: dataError) else {
            return .catchError(.unknown(error))
        }
        return .catchError(.noResponse(responseError))
    }
    
    private func handleDataRequestError(err: DataRequestError) -> ResponseError? {
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: .meet(id: meetId))
    }
}
