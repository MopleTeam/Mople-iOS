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
}

final class MeetDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case fetchMeetInfo
        case switchPage(isFuture: Bool)
        case pushMeetSetupView
        case editMeet(MeetPayload)
        case resetList
        case endFlow
        case planLoading(Bool)
        case reviewLoading(Bool)
        case catchError(MeetDetailError)
    }
    
    enum Mutation {
        case setMeetInfo(meet: Meet)
        case updateMeetInfoLoading(Bool)
        case updatePlanListLoading(Bool)
        case updateReviewListLoading(Bool)
        case catchError(MeetDetailError?)
    }
    
    struct State {
        @Pulse var meet: Meet?
        @Pulse var message: String?
        @Pulse var meetInfoLoaded: Bool = false
        @Pulse var futurePlanLoaded: Bool = false
        @Pulse var pastPlanLoaded: Bool = false
        @Pulse var error: MeetDetailError?
    }
    
    var initialState: State = State()
    private let meetId: Int
    private let fetchMeetUseCase: FetchMeetDetail
    private weak var coordinator: MeetDetailCoordination?
    public weak var planListCommands: MeetPlanListCommands?
    public weak var reviewListCommands: MeetReviewListCommands?
    
    init(fetchMeetUseCase: FetchMeetDetail,
         coordinator: MeetDetailCoordination,
         meetID: Int) {
        self.fetchMeetUseCase = fetchMeetUseCase
        self.coordinator = coordinator
        self.meetId = meetID
        action.onNext(.fetchMeetInfo)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchMeetInfo:
            return self.fetchMeetInfo()
        case let .switchPage(isFuture):
            coordinator?.swicthPlanListPage(isFuture: isFuture)
            return .empty()
        case let .planLoading(isLoading):
            return .just(.updatePlanListLoading(isLoading))
        case let .editMeet(payload):
            return handleMeetPayload(with: payload)
        case let .reviewLoading(isLoading):
            return .just(.updateReviewListLoading(isLoading))
        case .pushMeetSetupView:
            return pushMeetSetupView()
        case .resetList:
            return resetList()
        case .endFlow:
            coordinator?.endFlow()
            return .empty()
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

extension MeetDetailViewReactor {
    private func fetchMeetInfo() -> Observable<Mutation> {
        
        let fetchMeet = fetchMeetUseCase.execute(meetId: meetId)
            .asObservable()
            .map { Mutation.setMeetInfo(meet: $0) }
        
        return requestWithLoading(task: fetchMeet)
    }
}

extension MeetDetailViewReactor {
    private func pushMeetSetupView() -> Observable<Mutation> {
        guard let meet = currentState.meet else { return .empty() }
        coordinator?.pushMeetSetupView(meet: meet)
        return .empty()
    }
}

// MARK: - 알림 수신
extension MeetDetailViewReactor {
    
    /// 미팅 수정 알림 수신
    private func handleMeetPayload(with payload: MeetPayload) -> Observable<Mutation> {
        guard case .updated(let meet) = payload else { return .empty() }
        return .just(.setMeetInfo(meet: meet))
    }
    
    /// 날짜가 업데이트 된 경우
    private func resetList() -> Observable<Mutation> {
        planListCommands?.reset()
        reviewListCommands?.reset()
        return .empty()
    }
}

extension MeetDetailViewReactor: MeetDetailDelegate {
    func updateLoadingState(_ isLoading: Bool, index: Int) {
        switch index {
        case 0:
            action.onNext(.planLoading(isLoading))
        case 1:
            action.onNext(.reviewLoading(isLoading))
        default:
            break
        }
    }
    
    func selectedPlan(id: Int, type: PlanDetailType) {
        coordinator?.pushPlanDetailView(postId: id, type: type)
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

extension MeetDetailViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateMeetInfoLoading(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = handleDataRequestError(err: dataError) else {
            return .catchError(nil)
        }
        return .catchError(.noResponse(responseError))
    }
    
    private func handleDataRequestError(err: DataRequestError) -> ResponseError? {
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: .meet(id: meetId))
    }
}
