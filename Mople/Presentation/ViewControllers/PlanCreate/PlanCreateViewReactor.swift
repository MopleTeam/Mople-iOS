//
//  PlanCreateViewReactor.swift
//  Mople
//
//  Created by CatSlave on 12/9/24.
//

import Foundation
import ReactorKit

final class PlanCreateViewReactor: Reactor {
    
    enum Action {
        case setGroupId(id: Int)
        case setPlanName(name: String)
        case setPlanDate(date: DateComponents, type: UpdatePlanType)
        case setPlanAddress(address: String)
        case setPlanTime(date: DateComponents)
        case setLocation(location: (lot: Double, lat: Double))
        case setWeatherAddress(address: String)
        case requestPlanCreation
    }
    
    enum Mutation {
        case updateGroupId(_ id: Int)
        case updatePlanName(_ name: String)
        case updateDate(_ date: DateComponents)
        case updatePlanAddress(_ address: String)
        case updateWeatherAddress(_ address: String)
        case responsePlanCreation(_ plan: Plan)
        case notifyLoadingState(_ isLoading: Bool)
    }
    
    struct State {
        @Pulse var planCreationForm: PlanRequest?
        @Pulse var selectedDate: DateComponents?
        @Pulse var isLoading: Bool = false
        @Pulse var testCount: [Int] = Array(1...20)
    }
    
    private let createPlanUseCase: CreatePlanUsecase
    
    var initialState: State = State()
    
    init(createPlanUseCase: CreatePlanUsecase) {
        self.createPlanUseCase = createPlanUseCase
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .setGroupId(let id):
            return .just(.updateGroupId(id))
        case .setPlanName(let name):
            return .just(.updatePlanName(name))
        case let .setPlanDate(date, type):
            return self.updatePlanDate(on: date, type: type)
        case .setPlanAddress(let address):
            return .just(.updatePlanAddress(address))
        case .setPlanTime(let time):
            return self.updatePlanDate(on: time, type: .time)
        case .setLocation(let location):
            return self.updatePlanLocation(location: location)
        case .setWeatherAddress(let address):
            return .just(.updateWeatherAddress(address))
        case .requestPlanCreation:
            return .empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case .updateGroupId(let id):
            newState.planCreationForm?.meetId = id
        case .updatePlanName(let name):
            newState.planCreationForm?.name = name
        case .updateDate(let date):
            newState.selectedDate = date
        case .updatePlanAddress(let address):
            newState.planCreationForm?.address = address
        case .updateWeatherAddress(let address):
            newState.planCreationForm?.weatherAddress = address
        case .responsePlanCreation(let plan):
            break 
        case .notifyLoadingState(let isLoad):
            newState.isLoading = isLoad
        }
        
        return newState
    }
    
}

extension PlanCreateViewReactor {
    enum UpdatePlanType {
        case date
        case time
    }
    
    private func updatePlanDate(on date: DateComponents, type: UpdatePlanType) -> Observable<Mutation> {
        guard var currentDate = currentState.selectedDate else { return .empty() }
        
        switch type {
        case .date:
            currentDate.year = date.year
            currentDate.month = date.month
            currentDate.day = date.day
        case .time:
            currentDate.hour = date.hour
            currentDate.minute = date.minute
        }
        
        return .just(Mutation.updateDate(currentDate))
    }
    
    private func updatePlanLocation(location: (lot: Double, lat: Double)) -> Observable<Mutation> {
        guard var planCreationForm = currentState.planCreationForm else { return .empty() }
        planCreationForm.updateLocation(location)
        return .empty()
    }
    
    private func requestPlanCreation() -> Observable<Mutation> {
        guard var planCreationForm = currentState.planCreationForm,
              let date = currentState.selectedDate?.toDate() else { return .empty() }
        planCreationForm.updateDate(on: date)
        
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
}
