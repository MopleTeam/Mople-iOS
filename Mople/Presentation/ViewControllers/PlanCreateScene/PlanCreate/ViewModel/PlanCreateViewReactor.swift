//
//  PlanCreateViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/9/24.
//

import Foundation
import ReactorKit

final class PlanCreateViewReactor: Reactor {
    
    enum UpdatePlanType {
        case day
        case time
    }
    
    enum Action {
        enum SetValue {
            case meet(_ index: Int)
            case name(_ name: String)
            case date(_ date: DateComponents, type: UpdatePlanType)
            case place(_ location: PlaceInfo)
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
        case fetchMeetList
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
    }
    
    struct State {
        @Pulse var seletedMeet: MeetSummary?
        @Pulse var planTitle: String?
        @Pulse var selectedDay : DateComponents?
        @Pulse var selectedTime : DateComponents?
        @Pulse var place: UploadPlace?
        @Pulse var meets: [MeetSummary] = []
        @Pulse var isLoading: Bool = false
    }
    
    private let fetchMeetListUseCase: FetchGroup
    private let createPlanUseCase: CreatePlan
    private weak var flow: PlanCreateFlow?
    
    var initialState: State = State()
    
    init(createPlanUseCase: CreatePlan,
         fetchMeetListUSeCase: FetchGroup,
         flow: PlanCreateFlow) {
        print(#function, #line, "LifeCycle Test PlanCreateViewReactor Created" )

        self.createPlanUseCase = createPlanUseCase
        self.fetchMeetListUseCase = fetchMeetListUSeCase
        self.flow = flow
        self.action.onNext(.fetchMeetList)
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PlanCreateViewReactor Deinit" )
    }
        
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .setValue(value):
            return self.handleSetValueAction(value)
        case .requestPlanCreation:
            return self.requestPlanCreation()
        case .fetchMeetList:
            return self.fetchMeetList()
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
            self.flow?.endFlow(plan: plan)
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
}

extension PlanCreateViewReactor {
    
    private func fetchMeetList() -> Observable<Mutation> {
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        #warning("에러 처리")
        let updateMeet = fetchMeetListUseCase.fetchGroupList()
            .asObservable()
            .map({ $0.compactMap { meet in
                meet.meetSummary }
            })
            .map { Mutation.updateMeetList($0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  updateMeet,
                                  loadingStop])
    }
    
    private func requestPlanCreation() -> Observable<Mutation> {
        guard let planCreationForm = buliderPlanCreation() else { return .empty() }
        
        let loadingStart = Observable.just(Mutation.notifyLoadingState(true))
        
        #warning("에러 처리")
        let updatePlan = createPlanUseCase.createPlan(with: planCreationForm)
            .asObservable()
            .map { Mutation.responsePlanCreation($0) }
        
        let loadingStop = Observable.just(Mutation.notifyLoadingState(false))
        
        return Observable.concat([loadingStart,
                                  updatePlan,
                                  loadingStop])
    }
    
    private func buliderPlanCreation() -> PlanUploadRequest? {
        guard let date = self.createDate(),
              let meetId = currentState.seletedMeet?.id,
              let name = currentState.planTitle,
              let location = currentState.place else { return nil }
        
        return .init(meetId: meetId,
                     name: name,
                     date: DateManager.toServerDateString(date),
                     location: location)
    }
    
    private func createDate() -> Date? {
        guard let date = currentState.selectedDay,
              let time = currentState.selectedTime else { return nil }
        
        return DateComponents(year: date.year,
                              month: date.month,
                              day: date.day,
                              hour: time.hour,
                              minute: time.minute).toDate()
    }
    

}

// MARK: - Set Value
extension PlanCreateViewReactor {
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
            state.place = .init(title: place.title ?? "이름 없음",
                                planAddress: "",
                                lat: 0,
                                lot: 0,
                                weatherAddress: "")
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
        case let .place(location):
            return .just(.updateValue(.place(location)))
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
extension PlanCreateViewReactor {
    private func handleFlowAction(_ action: Action.FlowAction) -> Observable<Mutation> {
        switch action {
        case .groupSelectView:
            flow?.presentGroupSelectView()
        case .dateSelectView:
            flow?.presentDateSelectView()
        case .timeSelectView:
            flow?.presentTimeSelectView()
        case .placeSelectView:
            flow?.presentSearchLocationView()
        case .endProcess:
            flow?.endFlow(plan: nil)
        }
        return .empty()
    }
}

