//
//  PlanCreateViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/9/24.
//

import Foundation
import ReactorKit

struct CreatePlanAction {
    var completed:(() -> Void)?
}

final class PlanCreateViewReactor: Reactor {
    
    enum UpdatePlanType {
        case day
        case time
    }
    
    enum Action {
        case setSelectedMeet(index: Int)
        case setPlanName(name: String)
        case setPlanDate(date: DateComponents, type: UpdatePlanType)
        case setLocation(location: UploadLocation)
        case setMeetList(_ meets: [MeetSummary])
        case requestPlanCreation
    }
    
    enum Mutation {
        case updateSelectedMeet(_ meet: MeetSummary)
        case updatePlanName(_ name: String)
        case updateDate(_ date: DateComponents)
        case updateTime(_ date: DateComponents)
        case updateLocation(_ location: UploadLocation)
        case updateMeetList(_ meets: [MeetSummary])
        case responsePlanCreation(_ plan: Plan)
        case notifyLoadingState(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var seletedMeet: MeetSummary?
        @Pulse var planTitle: String?
        @Pulse var selectedDay : DateComponents?
        @Pulse var selectedTime : DateComponents?
        @Pulse var location: UploadLocation?
        @Pulse var meets: [MeetSummary] = []
        @Pulse var isLoading: Bool = false
    }
    
    private let createPlanUseCase: CreatePlanUsecase
    private let createPlanAction: CreatePlanAction
    
    var initialState: State = State()
    
    init(createPlanUseCase: CreatePlanUsecase,
         createPlanAction: CreatePlanAction,
         meets: [MeetSummary]) {
        self.createPlanUseCase = createPlanUseCase
        self.createPlanAction = createPlanAction
        self.action.onNext(.setMeetList(meets))
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setSelectedMeet(let index):
            return self.parseMeetId(selectedIndex: index)
        case .setPlanName(let name):
            return .just(.updatePlanName(name))
        case let .setPlanDate(date, type):
            return self.updateDate(date: date, type: type)
        case .setLocation(let location):
            return .just(.updateLocation(location))
        case .requestPlanCreation:
            return .empty()
        case .setMeetList(let meets):
            return .just(.updateMeetList(meets))
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .updateSelectedMeet(let meet):
            newState.seletedMeet = meet
        case .updatePlanName(let name):
            newState.planTitle = name
        case .updateDate(let date):
            newState.selectedDay = date
        case .updateTime(let time):
            newState.selectedTime = time
        case .updateLocation(let location):
            newState.location = location
        case .updateMeetList(let meets):
            newState.meets = meets
        case .responsePlanCreation(let plan):
            break 
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
    
}

extension PlanCreateViewReactor {
    
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
    
    private func updateDate(date: DateComponents, type: UpdatePlanType) -> Observable<Mutation> {
        switch type {
        case .day:
            return .just(.updateDate(date))
        case .time:
            return .just(.updateTime(date))
        }
    }
    
    private func buliderPlanCreation() -> PlanUploadRequest? {
        guard let date = self.createDate(),
              let meetId = currentState.seletedMeet?.id,
              let name = currentState.planTitle,
              let location = currentState.location else { return nil }
        
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
    
    private func parseMeetId(selectedIndex: Int) -> Observable<Mutation> {
        guard let meet = currentState.meets[safe: selectedIndex] else { return .empty() }
        return .just(.updateSelectedMeet(meet))
    }
}
