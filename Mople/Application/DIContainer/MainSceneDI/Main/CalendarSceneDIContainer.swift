//
//  CalendarSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import Foundation

protocol CalendarSceneDependencies {
    // MARK: - View
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController
    func makeCalendarViewController() -> CalendarViewController
    func makeScheduleListViewController() -> ScheduleListViewController
    
    // MARK: - Flow
    func makePlanDetailFlowCoordinator(postId: Int) -> BaseCoordinator
}

final class CalendarSceneDIContainer {
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory
    private var mainView: CalendarScheduleViewController?
    private var mainReactor: CalendarScheduleViewReactor?

    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
    }
    
    func makeCalendarFlowCoordinator() -> CalendarFlowCoordinator {
        let navi = AppNaviViewController(type: .main)
        navi.tabBarItem = .init(title: TextStyle.Tabbar.calendar,
                                image: .tabBarCalendar,
                                selectedImage: nil)
        return .init(navigationController: navi,
                     dependency: self)
    }
}

extension CalendarSceneDIContainer: CalendarSceneDependencies {
    // MARK: - 기본
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController {
        mainView = CalendarScheduleViewController(title: TextStyle.Tabbar.calendar,
                                                  reactor: makeCalendarViewReactor())
        return mainView!
    }

    private func makeCalendarViewReactor() -> CalendarScheduleViewReactor {
        mainReactor = CalendarScheduleViewReactor(fetchUseCase: FetchScheduleMock())
        return mainReactor!
    }
    
    // MARK: - 캘린더
    func makeCalendarViewController() -> CalendarViewController {
        return .init(reactor: makeCalendarViewReactor(),
                     verticalGestureObserver: mainView!.panGestureObserver)
    }
    
    private func makeCalendarViewReactor() -> CalendarViewReactor {
        let reactor = CalendarViewReactor(fetchCalendraDatesUseCase:
                                            makeFetchCalendarDatesUseCase(),
                                          delegate: mainReactor!)
        mainReactor?.calendarCommands = reactor
        return reactor
    }
    
    private func makeFetchCalendarDatesUseCase() -> FetchAllPlanDate {
        return FetchAllPlanDateUseCase(
            repo: DefaultCalendarRepo(networkService: appNetworkService)
        )
    }
    
    // MARK: - 스케줄 리스트
    func makeScheduleListViewController() -> ScheduleListViewController {
        let schdeuleListView = ScheduleListViewController(reactor: makeScheduleListReactor())
        schdeuleListView.panGestureRequire(mainView!.scopeGesture)
        return schdeuleListView
    }
    
    private func makeScheduleListReactor() -> ScheduleListReactor {
        let reactor = ScheduleListReactor(
            fetchMonthlyPlanUseCase: makeFetchMonthlyPlanUseCase(),
            delegate: mainReactor!
        )
        mainReactor?.scheduleListCommands = reactor
        return reactor
    }
    
    private func makeFetchMonthlyPlanUseCase() -> FetchMonthlyPlan {
        return FetchMonthlyPlanUseCase(
            repo: DefaultCalendarRepo(networkService: appNetworkService)
        )
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailFlowCoordinator(postId: Int) -> BaseCoordinator {
        return commonFactory.makePlanDetailCoordinator(postId: postId, type: .plan)
    }
}
