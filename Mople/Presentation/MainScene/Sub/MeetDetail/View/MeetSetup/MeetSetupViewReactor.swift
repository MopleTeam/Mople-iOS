//
//  MeetSetupViewReactor.swift
//  Mople
//
//  Created by CatSlave on 1/8/25.
//

import Foundation
import ReactorKit

protocol MeetSetupCoordination: NavigationCloseable {
    func pushEditMeetView(previousMeet: Meet)
    func pushMemberListView()
    func endFlow()
}

enum MeetSetupError: Error {
    case noResponse(ResponseError)
}

final class MeetSetupViewReactor: Reactor, LifeCycleLoggable {
    
    enum Action {
        enum Flow {
            case editMeet
            case memberList
            case pop
            case endFlow
        }
        
        case setMeet(_ meet: Meet)
        case editMeet(MeetPayload)
        case flow(Flow)
        case deleteMeet
    }
    
    enum Mutation {
        case updateMeet(_ meet: Meet)
        case checkHost(_ isHost: Bool)
        case updateLoadingState(Bool)
        case catchError(MeetSetupError?)
    }
    
    struct State {
        @Pulse var meet: Meet?
        @Pulse var isHost: Bool = false
        @Pulse var isLoading: Bool = false
        @Pulse var error: MeetSetupError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    private var isLoading = false
    
    // MARK: - UseCase
    private let deleteMeetUseCase: DeleteMeet
    
    // MARK: - Coordinator
    private weak var coordinator: MeetSetupCoordination?
    
    // MARK: - LifeCycle
    init(meet: Meet,
         deleteMeetUseCase: DeleteMeet,
         coordinator: MeetSetupCoordination) {
        self.deleteMeetUseCase = deleteMeetUseCase
        self.coordinator = coordinator
        initialAction(meet: meet)
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - Intial Setup
    private func initialAction(meet: Meet) {
        action.onNext(.setMeet(meet))
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        guard isLoading == false else { return .empty() }
        switch action {
        case let .setMeet(Meet):
            return self.setMeetInfo(Meet)
        case let .flow(action):
            return handleFlowAction(action)
        case let .editMeet(payload):
            return handleMeetPayload(with: payload)
        case .deleteMeet:
            return handleDeleteMeet()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateMeet(meet):
            newState.meet = meet
        case let .checkHost(isHost):
            newState.isHost = isHost
        case let .updateLoadingState(isLoading):
            newState.isLoading = isLoading
        case let .catchError(err):
            newState.error = err
        }
        
        return newState
    }
}

// MARK: - Set Meet
extension MeetSetupViewReactor {
    /// 모임 정보 설정 및 호스트 여부 확인
    private func setMeetInfo(_ meet: Meet) -> Observable<Mutation> {
        let userID = UserInfoStorage.shared.userInfo?.id
        
        let checkHost = Observable.just(Mutation.checkHost(userID == meet.creatorId))
        let updateMeet = Observable.just(Mutation.updateMeet(meet))
        
        return Observable.concat([checkHost, updateMeet])
    }
}

// MARK: - Data Request
extension MeetSetupViewReactor {
    /// 호스트 여부에 따라서 모임 삭제 및 모임 탈퇴
    private func handleDeleteMeet() -> Observable<Mutation> {
        guard let meetId = currentState.meet?.meetSummary?.id else { return .empty() }
        isLoading = true
        let deleteMeet = deleteMeetUseCase.execute(id: meetId)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMap { [weak self] _ -> Observable<Mutation> in
                self?.postDeleteMeet()
                self?.coordinator?.endFlow()
                return .empty()
            }
        
        return requestWithLoading(task: deleteMeet)
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
    }
}

// MARK: - Notify
extension MeetSetupViewReactor {
    private func postDeleteMeet() {
        guard let id = currentState.meet?.meetSummary?.id else { return }
        EventService.shared.postItem(MeetPayload.deleted(id: id),
                                     from: self)
    }
    
    private func handleMeetPayload(with payload: MeetPayload) -> Observable<Mutation> {
        switch payload {
        case let .updated(meet):
            return .just(.updateMeet(meet))
        default:
            return .empty()
        }
    }
}

// MARK: - Coordination
extension MeetSetupViewReactor {
    private func handleFlowAction(_ action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case .editMeet:
            guard let previousMeet = currentState.meet else { break }
            coordinator?.pushEditMeetView(previousMeet: previousMeet)
        case .memberList:
            coordinator?.pushMemberListView()
        case .pop:
            coordinator?.pop()
        case .endFlow:
            coordinator?.endFlow()
        }
        return .empty()
    }
}

// MARK: - Loading & Error
extension MeetSetupViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = getDataRequestError(err: dataError) else {
            return .catchError(nil)
        }
        return .catchError(.noResponse(responseError))
    }
    
    private func getDataRequestError(err: DataRequestError) -> ResponseError? {
        guard let meetId = currentState.meet?.meetSummary?.id else { return nil }
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: .meet(id: meetId))
    }
}
