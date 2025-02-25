//
//  ScheduleReactor.swift
//  Mople
//
//  Created by CatSlave on 2/24/25.
//

import Foundation
import ReactorKit

protocol ScheduleListCommands: AnyObject {
    func updatePlanMonthList(_ list: [DateComponents])
    func moveToPage(on month: DateComponents)
    func selectedDate(on date: Date)
}

final class ScheduleListReactor: Reactor {
    
    enum Action {
        enum ParentCommand {
            case selectedDate(Date)
            case loadMonthlyPlan(month: String)
        }
        
        enum ChildEvent {
            case scrollToDate(Date)
        }
        
        case parentCommand(ParentCommand)
        case childEvent(ChildEvent)
    }
    
    enum Mutation {
        case updateMonthlyPlan([MonthlyPlan])
        case updateSelectedDate(Date)
    }
    
    struct State {
        // var property: TYpe
        @Pulse var planList: [MonthlyPlan] = []
        @Pulse var selectedDate: Date?
    }
    
    var initialState: State = State()
    private let todayComponents = Date().toDateComponents()
    private let fetchMonthlyPlanUseCase: FetchMonthlyPlan
    private weak var delegate: SchduleListReactorDelegate?
    private var planMonthList: [DateComponents] = []
    private var planMonthStringList: [String] = []
    
    init(fetchMonthlyPlanUseCase: FetchMonthlyPlan,
         delegate: SchduleListReactorDelegate) {
        self.fetchMonthlyPlanUseCase = fetchMonthlyPlanUseCase
        self.delegate = delegate
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case let .parentCommand(action):
            switch action {
            case let .loadMonthlyPlan(month):
                return fetchMonthlyPlanWithRetry(month: month)
            case let .selectedDate(date):
                return .just(.updateSelectedDate(date))
            }
            
        case let .childEvent(event):
            return handleChildEvent(event)
        }
    }
    
    private func handleChildEvent(_ event: Action.ChildEvent) -> Observable<Mutation> {
        switch event {
        case let .scrollToDate(date):
            delegate?.scrollToDate(date: date)
        }
        
        return .empty()
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        
        var newState = state
        
        switch mutation {
        case let .updateMonthlyPlan(list):
            newState.planList.append(contentsOf: list)
        case let .updateSelectedDate(date):
            newState.selectedDate = date
        }
        
        return newState
    }
}

extension ScheduleListReactor: ScheduleListCommands {
    func updatePlanMonthList(_ list: [DateComponents]) {
        let convertDate = list.compactMap { $0.toDate() }
        let sortedList = convertDate.sorted()
        planMonthStringList = sortedList.compactMap({ DateManager.toString(date: $0,
                                                                                format: .month)})
        planMonthList = sortedList.map({ $0.toDateComponents() })
        
        guard let firstMonth = planMonthStringList.first else { return }
        action.onNext(.parentCommand(.loadMonthlyPlan(month: firstMonth)))
    }
    
    func moveToPage(on month: DateComponents) {
        guard let monthString = DateManager.toString(date: month.toDate(),
                                               format: .month),
              planMonthStringList.contains(where: { $0 == monthString }) else { return }
        action.onNext(.parentCommand(.loadMonthlyPlan(month: monthString)))
    }
    
    func selectedDate(on date: Date) {
        action.onNext(.parentCommand(.selectedDate(date)))
    }

    
}

extension ScheduleListReactor {
    
    /// 데이터가 적고 추가로 불러올 수 있는 달이 있다면 재귀호출
    private func fetchMonthlyPlanWithRetry(month: String) -> Observable<Mutation> {
        return recursiveFetchMonthlyPlan(month: month,
                                         accumulated: [])
    }
    
    private func recursiveFetchMonthlyPlan(month: String,
                                           accumulated: [MonthlyPlan]) -> Observable<Mutation> {
        return fetchMonthlyPlanUseCase.execute(month: month)
            .asObservable()
            .do(onNext: { [weak self] _ in
                self?.planMonthStringList.removeAll(where: { $0 == month })
            })
            .map({ $0 + accumulated })
            .flatMap { [weak self] plans -> Observable<Mutation> in
                guard let self else { return .just(.updateMonthlyPlan(plans))}
                
                guard plans.count < 5,
                      let nextMonth = planMonthStringList.first else {
                    return .just(.updateMonthlyPlan(plans))
                }
                
                return recursiveFetchMonthlyPlan(month: nextMonth,
                                                 accumulated: plans)
            }
    }
}

