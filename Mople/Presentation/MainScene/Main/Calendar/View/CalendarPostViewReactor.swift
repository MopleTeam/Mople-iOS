//
//  CalendarViewReactor.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import ReactorKit

protocol CalendarReactorDelegate: AnyObject, ChildLoadingDelegate {
    func updatePostMonthList(_ list: [Date])
}

protocol PostListReactorDelegate: AnyObject, ChildLoadingDelegate {
    func updateDateList(type: EventUpdateType)
}

enum CalendarError: Error {
    case midnight(DateTransitionError)
    case unknown(Error)
}

final class CalendarPostViewReactor: Reactor, LifeCycleLoggable {
    
    typealias ScopeChangeType = CalendarViewController.ScopeChangeType
    
    enum Action {
        enum Flow {
            case postDetail(MonthlyPost)
        }
        
        enum Notify {
            case updatePlan(PlanPayload)
            case updateMeet(MeetPayload)
            case updateReview(ReviewPayload)
            case midnightUpdate
        }
        
        case flow(Flow)
        case changeLoadingState(Bool)
        case notify(Notify)
        case catchError(CalendarError)
    }
    
    enum Mutation {
        case updateLoadingState(Bool)
        case catchError(CalendarError)
    }
    
    struct State {
        @Pulse var isLoading: Bool = false
        @Pulse var error: CalendarError?
    }
    
    // MARK: - Variables
    var initialState: State = State()
    
    // MARK: - Coordinator
    private weak var coordinator: CalendarCoordination?
    
    // MARK: - Commands
    public weak var calendarCommands: CalendarCommands?
    public weak var scheduleListCommands: PostListCommands?
    
    // MARK: - LifeCycle
    init(coordinator: CalendarCoordination) {
        self.coordinator = coordinator
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
    
    // MARK: - State Mutation
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .notify(action):
            return handleNotification(action: action)
        case let .flow(action):
            return handleFlow(action: action)
        case let .changeLoadingState(isLoad):
            return .just(.updateLoadingState(isLoad))
        case let .catchError(err):
            return .just(.catchError(err))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateLoadingState(isLoad):
            newState.isLoading = isLoad
        case let .catchError(err):
            newState.error = err
        }
        return newState
    }
}

// MARK: - Action Handling
extension CalendarPostViewReactor {
    private func handleNotification(action: Action.Notify) -> Observable<Mutation> {
        switch action {
        case let .updateMeet(payload):
            return handleMeetPayload(payload)
        case let .updatePlan(payload):
            return handlePlanPayload(payload)
        case let .updateReview(payload):
            return handleReviewPayload(payload)
        case .midnightUpdate:
            return midnightUpdate()
        }
    }
}

// MARK: - Calendar Deleagte
extension CalendarPostViewReactor: CalendarReactorDelegate {
    func updatePostMonthList(_ list: [Date]) {
        scheduleListCommands?.setInitialList(with: list)
    }
}

// MARK: - Post List Delegate
extension CalendarPostViewReactor: PostListReactorDelegate {
    func updateDateList(type: EventUpdateType) {
        calendarCommands?.updateEvent(type: type)
    }
}

// MARK: - Coordination
extension CalendarPostViewReactor {
    private func handleFlow(action: Action.Flow) -> Observable<Mutation> {
        switch action {
        case let .postDetail(monthlyPost):
            guard let id = monthlyPost.id else { return .empty() }
            let postType: PostType = monthlyPost.type == .plan ? .plan : .review
            coordinator?.pushPostDetailView(postId: id, type: postType)
        }
        
        return .empty()
    }
    
    /// 일정 선택 시 타입과 날짜를 확인 후 맞는 타입으로 delegate에게 전달
    private func checkVaildPost(with monthlyPost: MonthlyPost) -> Observable<Mutation> {
        if isValidPost(with: monthlyPost) {
            guard let id = monthlyPost.id else { return .empty() }
            let postType: PostType = monthlyPost.type == .plan ? .plan : .review
            coordinator?.pushPostDetailView(postId: id, type: postType)
            return .empty()
        } else {
            return .just(.catchError(.midnight(.midnightReset)))
        }
    }
    
    private func isValidPost(with post: MonthlyPost) -> Bool {
        guard let postDate = post.date else { return false }
        let isReview = post.type == .review
        let isPlan = !DateManager.isPastDay(on: postDate)
        return isReview || isPlan
    }
}

// MARK: - Notify
extension CalendarPostViewReactor {
    private func handleMeetPayload(_ payload: MeetPayload) -> Observable<Mutation> {
        switch payload {
        case .deleted:
            calendarCommands?.resetDate()
        case .updated:
            scheduleListCommands?.editMeet(payload: payload)
        default:
            break
        }
        return .empty()
    }
    
    private func handlePlanPayload(_ payload: PlanPayload) -> Observable<Mutation> {
        scheduleListCommands?.editPlan(payload: payload)
        return .empty()
    }
    
    private func handleReviewPayload(_ payload: ReviewPayload) -> Observable<Mutation> {
        scheduleListCommands?.editReview(payload: payload)
        return .empty()
    }
    
    private func midnightUpdate() -> Observable<Mutation> {
        scheduleListCommands?.updateWhenMidnight()
        return .empty()
    }
}

// MARK: - Loading & Error
extension CalendarPostViewReactor: ChildLoadingDelegate {
    func updateLoadingState(_ isLoading: Bool, index: Int) {
        action.onNext(.changeLoadingState(isLoading))
    }
    
    func catchError(_ error: Error, index: Int) {
        switch error {
        case let error as DateTransitionError:
            action.onNext(.catchError(.midnight(error)))
        default:
            action.onNext(.catchError(.unknown(error)))
        }
    }
}
