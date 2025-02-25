//
//  PlanCreateViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/9/24.
//

import Foundation
import ReactorKit

enum PlanCreationType {
    case create([MeetSummary])
    case edit(Plan)
}

final class CreatePlanViewReactor: Reactor, LifeCycleLoggable {
    
    enum DateError: Error {
        case invalid
        
        var info: String {
            "선택된 시간이 너무 이릅니다."
        }
    }
    
    enum UpdatePlanType {
        case day
        case time
    }
    
    enum Action {
        enum SetValue {
            case meet(_ index: Int)
            case name(_ name: String)
            case date(_ date: DateComponents, type: UpdatePlanType)
            case place(_ placeInfo: PlaceInfo)
        }

        enum FlowAction {
            case groupSelectView
            case dateSelectView
            case timeSelectView
            case placeSelectView
            case endProcess
        }
        
        case setValue(SetValue)
        case flowAction(FlowAction)
        
        case fetchPreviousPlan(Plan)
        case fetchMeetList([MeetSummary])
        case requestPlanCreation
    }
    
    enum Mutation {
        enum UpdateValue {
            case meet(_ meet: MeetSummary)
            case name(_ name: String)
            case date(_ date: DateComponents)
            case time(_ date: DateComponents)
            case place(_ location: PlaceInfo)
        }
        
        case updateValue(UpdateValue)
        case updatePreviousPlan(Plan)
        case updateMeetList(_ meets: [MeetSummary])
        case notifyLoadingState(_ isLoading: Bool)
        case notifyMessage(_ message: String)
    }
    
    struct State {
        @Pulse var seletedMeet: MeetSummary?
        @Pulse var planTitle: String?
        @Pulse var selectedDay : DateComponents?
        @Pulse var selectedTime : DateComponents?
        @Pulse var selectedPlace: UploadPlace?
        @Pulse var meets: [MeetSummary] = []
        @Pulse var isLoading: Bool = false
        @Pulse var message: String?
        @Pulse var previousPlan: Plan?
        
        var canComplete: Bool {
            guard planTitle?.isEmpty == false else { return false }
            
            if let previousPlan {
                return isChanged(previousPlan: previousPlan)
            } else {
                return isFilled()
            }
        }
    }
    
    // MARK: - Variable
    private let type: PlanCreationType
    
    private let createPlanUseCase: CreatePlan
    private let editPlanUseCase: EditPlan
    private weak var coordinator: PlanCreateCoordination?
    
    var initialState: State = State()
    
    init(createPlanUseCase: CreatePlan,
         editPlanUseCase: EditPlan,
         type: PlanCreationType,
         coordinator: PlanCreateCoordination) {
        self.createPlanUseCase = createPlanUseCase
        self.editPlanUseCase = editPlanUseCase
        self.coordinator = coordinator
        self.type = type
        handleViewType()
        logLifeCycle()
    }
    
    deinit {
        logLifeCycle()
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setValue(value):
            return self.handleSetValueAction(value)
        case .requestPlanCreation:
            return self.handleCreation()
        case let .fetchMeetList(meets):
            return .just(.updateMeetList(meets))
        case .flowAction(let action):
            return self.handleFlowAction(action)
        case let .fetchPreviousPlan(plan):
            return .just(.updatePreviousPlan(plan))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateValue(value):
            self.handleValueMutation(&newState, value: value)
        case .updateMeetList(let meets):
            newState.meets = meets
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        case let .notifyMessage(message):
            newState.message = message
        case let .updatePreviousPlan(plan):
            setPreviousPlan(state: &newState, plan)
        }
        
        return newState
    }
    
    private func setPreviousPlan(state: inout State, _ plan: Plan) {
        guard let meet = plan.meet,
              let title = plan.title,
              let date = plan.date else { return }
        
        let day = date.toDateComponents()
        let time = date.getTime()
        let place = UploadPlace(plan: plan)
        
        state.seletedMeet = meet
        state.planTitle = title
        state.selectedDay = day
        state.selectedTime = time
        state.selectedPlace = place
        state.previousPlan = plan
    }
    
    private func handleViewType() {
        switch type {
        case let .create(meets):
            action.onNext(.fetchMeetList(meets))
        case let .edit(plan):
            action.onNext(.fetchPreviousPlan(plan))
        }
    }
}

extension CreatePlanViewReactor {
    
    private func handleCreation() -> Observable<Mutation> {
        guard let request = try? buliderPlanRequset() else {
            return .just(.notifyMessage(DateError.invalid.info))
        }
        
        switch type {
        case .create:
            return createPlan(request: request)
        case .edit:
            return editPlan(request: request)
        }
    }
}

// MARK: - 일정 생성 및 일정 유효성 체크
extension CreatePlanViewReactor {
    private func createPlan(request: PlanRequest) -> Observable<Mutation> {
        let uploadPlan = createPlanUseCase.execute(request: request)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] in self?.notificationNewPlan($0) })
            .flatMap({ _ in Observable<Mutation>.empty() })
        
        return requestWithLoading(task: uploadPlan) { [weak self] in
            self?.coordinator?.endFlow()
        }
    }
    
    private func editPlan(request: PlanRequest) -> Observable<Mutation> {
        let editPlan = editPlanUseCase.execute(request: request)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] in self?.notificationNewPlan($0) })
            .flatMap({ _ in Observable<Mutation>.empty() })
        
        return requestWithLoading(task: editPlan) { [weak self] in
            self?.coordinator?.endFlow()
        }
    }
    
    private func requestWithLoading(task: Observable<Mutation>,
                                    completion: (() -> Void)? = nil) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let loadingStop = Observable.just(())
            .do(onNext: { completion?() })
            .flatMap({ _ -> Observable<Mutation> in
                return .just(.notifyLoadingState(false))
            })
        
        return .concat([loadingStart,
                        task,
                        loadingStop])
    }
    
    private func buliderPlanRequset() throws -> PlanRequest? {
        guard let date = try self.createDate(),
              let name = currentState.planTitle,
              let location = currentState.selectedPlace else { return nil }
        
        let requestType: PlanRequestType
        
        switch type {
        case .create:
            guard let meetId = currentState.seletedMeet?.id else { return nil }
            requestType = .create(meetId: meetId)
        case let .edit(plan):
            guard let planId = plan.id else { return nil }
            requestType = .edit(planId: planId)
        }
        
        return .init(type: requestType,
                     name: name,
                     date: DateManager.toServerDateString(date),
                     place: location)
    }
    
    private func createDate() throws -> Date? {
        guard let day = currentState.selectedDay,
              let time = currentState.selectedTime,
              let combineDate = DateManager.combineDayAndTime(day: day,
                                                              time: time) else { return nil }
        return try checkValidDate(combineDate)
    }
    
    private func checkValidDate(_ date: Date) throws -> Date {
        guard date > DateManager.addFiveMinutes(Date()) else { throw DateError.invalid }
        return date
    }
    
    private func notificationNewPlan(_ plan: Plan) {
        switch type {
        case .create:
            EventService.shared.postItem(.created(plan),
                                         from: self)
        case .edit:
            EventService.shared.postItem(.updated(plan),
                                         from: self)
        }
    }
}

// MARK: - Set Value
extension CreatePlanViewReactor {
    private func handleValueMutation(_ state: inout State, value: Mutation.UpdateValue) {
        switch value {
        case .meet(let meet):
            state.seletedMeet = meet
        case .name(let name):
            state.planTitle = name
        case .date(let date):
            state.selectedDay = date
        case .time(let time):
            state.selectedTime = time
        case .place(let place):
            state.selectedPlace = .init(place: place)
        }
    }
    
    private func handleSetValueAction(_ action: Action.SetValue)  -> Observable<Mutation> {
        switch action {
        case let .meet(index):
            return self.parseMeetId(selectedIndex: index)
        case let .name(name):
            return .just(.updateValue(.name(name)))
        case let .date(date, type):
            return self.updateDate(date: date, type: type)
        case let .place(placeInfo):
            return .just(.updateValue(.place(placeInfo)))
        }
    }
    
    private func parseMeetId(selectedIndex: Int) -> Observable<Mutation> {
        guard let meet = currentState.meets[safe: selectedIndex] else { return .empty() }
        return .just(.updateValue(.meet(meet)))
    }
    
    private func updateDate(date: DateComponents, type: UpdatePlanType) -> Observable<Mutation> {
        switch type {
        case .day:
            return .just(.updateValue(.date(date)))
        case .time:
            return .just(.updateValue(.time(date)))
        }
    }
}

// MARK: - Flow Action
extension CreatePlanViewReactor {
    private func handleFlowAction(_ action: Action.FlowAction) -> Observable<Mutation> {
        switch action {
        case .groupSelectView:
            coordinator?.presentGroupSelectView()
        case .dateSelectView:
            coordinator?.presentDateSelectView()
        case .timeSelectView:
            coordinator?.presentTimeSelectView()
        case .placeSelectView:
            coordinator?.presentSearchLocationView()
        case .endProcess:
            coordinator?.endFlow()
        }
        return .empty()
    }
}

extension CreatePlanViewReactor.State {
    private func isFilled() -> Bool {
        return seletedMeet != nil &&
        planTitle != nil &&
        selectedDay != nil &&
        selectedTime != nil &&
        selectedPlace != nil
    }
    
    private func isChanged(previousPlan: Plan) -> Bool {
        guard let selectedDay,
              let selectedTime,
              let selectedDate = DateManager.combineDayAndTime(day: selectedDay,
                                                               time: selectedTime) else {
            return false
        }
        
        return planTitle != previousPlan.title ||
        selectedDate != previousPlan.date ||
        selectedPlace != UploadPlace(plan: previousPlan)
    }
}

