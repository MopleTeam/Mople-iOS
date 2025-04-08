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

enum CreatePlanError: Error {
    case midnight(DateTransitionError)
    case noResponse(ResponseError)
    case unknown(Error)
    case invalid
    
    var info: String? {
        switch self {
        case .invalid:
            return "선택된 시간이 너무 이릅니다."
        default:
            return nil
        }
    }
}

final class CreatePlanViewReactor: Reactor, LifeCycleLoggable {
    
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
        case updateMeet(MeetPayload)
        case requestPlanCreation
    }
    
    enum Mutation {
        enum UpdateValue {
            case meet(_ meet: MeetSummary?)
            case name(_ name: String)
            case date(_ date: DateComponents)
            case time(_ date: DateComponents)
            case place(_ location: PlaceInfo)
        }
        
        case updateValue(UpdateValue)
        case updatePreviousPlan(Plan)
        case updateMeetList(_ meets: [MeetSummary])
        case updateLoadingState(Bool)
        case catchError(CreatePlanError)
    }
    
    struct State {
        @Pulse var seletedMeet: MeetSummary?
        @Pulse var planTitle: String?
        @Pulse var selectedDay : DateComponents?
        @Pulse var selectedTime : DateComponents?
        @Pulse var selectedPlace: UploadPlace?
        @Pulse var meets: [MeetSummary] = []
        @Pulse var isLoading: Bool = false
        @Pulse var error: CreatePlanError?
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
    private var isLoading: Bool = false
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
        case let .updateMeet(payload):
            return handleMeetPayload(payload)
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateValue(value):
            self.handleValueMutation(&newState, value: value)
        case .updateMeetList(let meets):
            newState.meets = meets
        case .updateLoadingState(let isLoad):
            newState.isLoading = isLoad
        case let .catchError(err):
            newState.error = err
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
        guard isLoading == false else { return .empty() }
        guard let request = try? buliderPlanRequset() else {
            return .just(.catchError(CreatePlanError.invalid))
        }
        isLoading = true
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
            .flatMap({ [weak self] plan -> Observable<Mutation> in
                self?.postNewPlan(plan)
                self?.coordinator?.endFlow()
                return .empty()
            })
        
        return requestWithLoading(task: uploadPlan)
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
    }
    
    private func editPlan(request: PlanRequest) -> Observable<Mutation> {
        guard let date = currentState.previousPlan?.date,
              DateManager.isPastDay(on: date) == false else {
            return .just(.catchError(.midnight(.midnightReset)))
        }
        
        let editPlan = editPlanUseCase.execute(request: request)
            .asObservable()
            .observe(on: MainScheduler.instance)
            .flatMap({ [weak self] plan -> Observable<Mutation> in
                self?.postNewPlan(plan)
                self?.coordinator?.endFlow()
                return .empty()
            })
        
        return requestWithLoading(task: editPlan)
            .do(onDispose: { [weak self] in
                self?.isLoading = false
            })
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
        guard date > DateManager.addFiveMinutes(Date()) else { throw CreatePlanError.invalid }
        return date
    }
    
    private func postNewPlan(_ plan: Plan) {
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
        let meet = currentState.meets[safe: selectedIndex]
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

extension CreatePlanViewReactor: SearchPlaceDelegate {
    func selectedPlace(with place: PlaceInfo) {
        action.onNext(.setValue(.place(place)))
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

// MARK: - 페이로드
extension CreatePlanViewReactor {
    private func handleMeetPayload(_ payload: MeetPayload) -> Observable<Mutation> {
        guard case .deleted(let id) = payload else { return .empty() }
        var currentMeetList = currentState.meets
        currentMeetList.removeAll { $0.id == id }
        return .of(.updateMeetList(currentMeetList),
                   .updateValue(.meet(nil)))
    }
}

// MARK: - 로딩
extension CreatePlanViewReactor: LoadingReactor {
    func updateLoadingMutation(_ isLoading: Bool) -> Mutation {
        return .updateLoadingState(isLoading)
    }
    
    func catchErrorMutation(_ error: Error) -> Mutation {
        guard let dataError = error as? DataRequestError,
              let responseError = getDataRequestError(err: dataError) else {
            return .catchError(.unknown(error))
        }
        
        return .catchError(.noResponse(responseError))
    }
    
    private func getDataRequestError(err: DataRequestError) -> ResponseError? {
        guard let meetId = getMeetId() else { return nil }
        return DataRequestError.resolveNoResponseError(err: err,
                                                       responseType: .meet(id: meetId))
    }
    
    private func getMeetId() -> Int? {
        switch type {
        case .create:
            return currentState.seletedMeet?.id
        case .edit:
            return currentState.previousPlan?.meet?.id
        }
    }
}
