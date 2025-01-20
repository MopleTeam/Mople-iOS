//
//  PlanCreateViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/9/24.
//

import Foundation
import ReactorKit

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
        case fetchMeetList(_ meets: [MeetSummary])
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
        case updateMeetList(_ meets: [MeetSummary])
        case responsePlanCreation(_ plan: Plan)
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
        
        var isAllFieldsFilled: Bool {
            return seletedMeet != nil &&
            planTitle != nil &&
            planTitle?.isEmpty == false &&
            selectedDay != nil &&
            selectedTime != nil &&
            selectedPlace != nil
        }
    }
    
    private let createPlanUseCase: CreatePlan
    private weak var coordinator: PlanCreateCoordination?
    
    var initialState: State = State()
    
    init(createPlanUseCase: CreatePlan,
         meetList: [MeetSummary],
         coordinator: PlanCreateCoordination) {
        self.createPlanUseCase = createPlanUseCase
        self.coordinator = coordinator
        logLifeCycle()
        self.action.onNext(.fetchMeetList(meetList))
    }
    
    deinit {
        logLifeCycle()
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setValue(value):
            return self.handleSetValueAction(value)
        case .requestPlanCreation:
            return self.requestPlanCreation()
        case let .fetchMeetList(meets):
            return .just(.updateMeetList(meets))
        case .flowAction(let action):
            return self.handleFlowAction(action)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateValue(value):
            self.handleValueMutation(&newState, value: value)
        case .updateMeetList(let meets):
            newState.meets = meets
        case .responsePlanCreation(let plan):
            self.coordinator?.endFlow()
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        case let .notifyMessage(message):
            newState.message = message
        }
        
        return newState
    }
}

extension CreatePlanViewReactor {
    
#warning("에러 처리")
    private func requestPlanCreation() -> Observable<Mutation> {
        do {
            guard let planCreationForm = try buliderPlanCreation() else { throw DateError.invalid }
            return self.createPlan(planCreationForm)
        } catch {
            if let err = error as? DateError {
                return .just(.notifyMessage(err.info))
            } else {
                return .just(.notifyMessage("Unknown Error"))
            }
        }
    }
}

// MARK: - 일정 생성 및 일정 유효성 체크
extension CreatePlanViewReactor {
    private func createPlan(_ plan: CreatePlanRequest) -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        let uploadPlan = createPlanUseCase.execute(with: plan)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] in self?.notificationNewPlan($0) })
            .map { Mutation.responsePlanCreation($0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  uploadPlan,
                                  loadingStop])
    }
    
    private func buliderPlanCreation() throws -> CreatePlanRequest? {
        guard let date = try self.createDate(),
              let meetId = currentState.seletedMeet?.id,
              let name = currentState.planTitle,
              let location = currentState.selectedPlace else { return nil }
        
        return .init(meetId: meetId,
                     name: name,
                     date: DateManager.toServerDateString(date),
                     place: location)
    }
    
    private func createDate() throws -> Date? {
        guard let date = currentState.selectedDay,
              let time = currentState.selectedTime,
              let combineDate = DateComponents(year: date.year,
                                               month: date.month,
                                               day: date.day,
                                               hour: time.hour,
                                               minute: time.minute).toDate() else { return nil }
        return try checkValidDate(combineDate)
    }
    
    private func checkValidDate(_ date: Date) throws -> Date {
        guard date > DateManager.addFiveMinutes(Date()) else { throw DateError.invalid }
        return date
    }
    
    private func notificationNewPlan(_ plan: Plan) {
        EventService.shared.postItem(.created(plan),
                                     from: self)
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

