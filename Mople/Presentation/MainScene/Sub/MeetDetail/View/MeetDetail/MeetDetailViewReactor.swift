//
//  DetailGroupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import Foundation
import ReactorKit

protocol MeetDetailDelegate: AnyObject, ChildLoadingDelegate { }

enum MeetDetailError: Error { }

final class MeetDetailViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        case updateMeetInfo(id: Int)
        case switchPage(isFuture: Bool)
        case pushMeetSetupView
        case editMeet(MeetPayload)
        case planLoading(Bool)
        case reviewLoading(Bool)
        case resetList
        case endFlow
        case catchChildError(MeetDetailError)
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
    }
    
    var initialState: State = State()
    
    private let fetchMeetUseCase: FetchMeetDetail
    private weak var coordinator: MeetDetailCoordination?
    public weak var planListCommands: MeetPlanListCommands?
    public weak var reviewListCommands: MeetReviewListCommands?
    
    init(fetchMeetUseCase: FetchMeetDetail,
         coordinator: MeetDetailCoordination,
         meetID: Int) {
        self.fetchMeetUseCase = fetchMeetUseCase
        self.coordinator = coordinator
        action.onNext(.updateMeetInfo(id: meetID))
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .updateMeetInfo(id):
            return self.fetchMeetInfo(id: id)
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
        case let .catchChildError(err):
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
            handleError(state: &newState, err: err)
        }
        
        return newState
    }
    
    private func handleError(state: inout State,
                             err: MeetDetailError) {

        // 에러처리
    }
}

extension MeetDetailViewReactor {
    private func fetchMeetInfo(id: Int) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.updateMeetInfoLoading(true))
        
        #warning("에러 처리")
        let updateMeet = fetchMeetUseCase.execute(meetId: id)
            .asObservable()
            .map { Mutation.setMeetInfo(meet: $0) }
        
        let loadingStop = Observable.just(Mutation.updateMeetInfoLoading(false))
        
        return Observable.concat([loadingStart,
                                  updateMeet,
                                  loadingStop])
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
    
    func catchError(_ error: any Error, index: Int) {
        guard let meetDetailErr = error as? MeetDetailError else { return }
        action.onNext(.catchChildError(meetDetailErr))
    }
}
