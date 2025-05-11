//
//  CalendarViewReactor.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import ReactorKit

protocol CalendarReactorDelegate: AnyObject, ChildLoadingDelegate {
    func updatePage(_ page: Date)
    func updateMonth(_ month: DateComponents)
    func updatePostMonthList(_ list: [Date])
    func updateScope(_ scope: ScopeType)
    func selectedDate(date: Date)
}

protocol PostListReactorDelegate: AnyObject, ChildLoadingDelegate {
    func scrollToDate(date: Date)
    func updateDateList(type: EventUpdateType)
    func selectedPost(id: Int, type: PostType)
    func deleteMonth(month: Date)
}

enum CalendarError: Error {
    case midnight(DateTransitionError)
    case unknown(Error)
}

final class CalendarPostViewReactor: Reactor, LifeCycleLoggable {
    
    typealias ScopeChangeType = CalendarViewController.ScopeChangeType
    
    enum Action {
        enum CalendarActions {
            case changedMonth(DateComponents)
            case changedScope(ScopeType)
        }
        
        enum Notify {
            case updatePlan(PlanPayload)
            case updateMeet(MeetPayload)
            case updateReview(ReviewPayload)
            case midnightUpdate
        }
        
        case calendarAction(CalendarActions)
        case changeScope
        case changeMonth(Date)
        case changeLoadingState(Bool)
        case notify(Notify)
        case catchError(CalendarError)
    }
    
    enum Mutation {
        enum CalendarEvents {
            case updateMonth(DateComponents)
            case updateScope(ScopeType)
        }
        
        case calendarEvent(CalendarEvents)
        case updateLoadingState(Bool)
        case catchError(CalendarError)
    }
    
    struct State {
        @Pulse var scope: ScopeType = .month
        @Pulse var changeMonth: DateComponents?
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
        case let .calendarAction(action):
            return handleCalendarAction(action)
        case let .changeMonth(month):
            return monthChange(month)
        case .changeScope:
            return calendarScopeChange()
        case let .changeLoadingState(isLoad):
            return .just(.updateLoadingState(isLoad))
        case let .notify(action):
            return handleNotification(action: action)
        case let .catchError(err):
            return .just(.catchError(err))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .calendarEvent(event):
            handleCalendarEvent(state: &newState,
                                event: event)
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
    private func handleCalendarAction(_ action: Action.CalendarActions) -> Observable<Mutation> {
        switch action {
        case let .changedMonth(page):
            return .just(.calendarEvent(.updateMonth(page)))
        case let .changedScope(scope):
            return .just(.calendarEvent(.updateScope(scope)))
        }
    }
    
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

extension CalendarPostViewReactor {
    private func handleCalendarEvent(state: inout State, event: Mutation.CalendarEvents) {
        switch event {
        case let .updateMonth(month):
            state.changeMonth = month
        case let .updateScope(scope):
            state.scope = scope
        }
    }
}

// MARK: - 부모 -> 자식
extension CalendarPostViewReactor {
    private func monthChange(_ month: Date) -> Observable<Mutation> {
        scheduleListCommands?.fetchMonthPlan(on: month)
        calendarCommands?.changePage(on: month)
        return .empty()
    }
    
    private func calendarScopeChange() -> Observable<Mutation> {
        calendarCommands?.changeScope()
        return .empty()
    }
}

// MARK: - Calendar Deleagte
extension CalendarPostViewReactor: CalendarReactorDelegate {
    
    func updateScope(_ scope: ScopeType) {
        action.onNext(.calendarAction(.changedScope(scope)))
    }
    
    func updateMonth(_ month: DateComponents) {
        action.onNext(.calendarAction(.changedMonth(month)))
    }
    
    func updatePostMonthList(_ list: [Date]) {
        scheduleListCommands?.setInitialList(with: list)
    }
    
    func updatePage(_ page: Date) {
        scheduleListCommands?.loadMonthlyPost(on: page)
    }
    
    func selectedDate(date: Date) {
        scheduleListCommands?.selectedDate(on: date)
    }
}

// MARK: - Post List Delegate
extension CalendarPostViewReactor: PostListReactorDelegate {
    func scrollToDate(date: Date) {
        calendarCommands?.scrollToDate(on: date)
    }
    
    func selectedPost(id: Int, type: PostType) {
        coordinator?.pushPostDetailView(postId: id,
                                        type: type)
    }
    
    func updateDateList(type: EventUpdateType) {
        calendarCommands?.updateEvent(type: type)
    }
    
    func deleteMonth(month: Date) {
        calendarCommands?.deleteMonth(month: month)
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
