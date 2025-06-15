//
//  CalendarSceneDIContainer.swift
//  Mople
//
//  Created by CatSlave on 1/13/25.
//

import Foundation

protocol CalendarSceneDependencies {
    // MARK: - View
    func makeCalendarScheduleViewcontroller(coordinator: CalendarCoordination) -> CalendarPostViewController
    
    // MARK: - Flow
    func makePlanDetailFlowCoordinator(postId: Int,
                                       type: PostType) -> BaseCoordinator
}

final class CalendarSceneDIContainer: BaseContainer, CalendarSceneDependencies {
    
    private var mainView: CalendarPostViewController?
    private var mainReactor: CalendarPostViewReactor?
    
    func makeCalendarFlowCoordinator() -> CalendarFlowCoordinator {
        let navi = AppNaviViewController(type: .main)
        navi.tabBarItem = .init(title: L10n.calendar,
                                image: .tabBarCalendar,
                                selectedImage: nil)
        return .init(navigationController: navi,
                     dependency: self)
    }
}

// MARK: - Default View
extension CalendarSceneDIContainer {
    
    // MARK: - 메인
    func makeCalendarScheduleViewcontroller(coordinator: CalendarCoordination) -> CalendarPostViewController {
        mainReactor = makeCalendarViewReactor(coordinator: coordinator)
        mainView = CalendarPostViewController(screenName: .calendar,
                                              title: L10n.calendar,
                                              calendarVC: makeCalendarViewController(),
                                              scheduleVC: makeScheduleListViewController(),
                                              reactor: mainReactor!)
        return mainView!
    }

    private func makeCalendarViewReactor(coordinator: CalendarCoordination) -> CalendarPostViewReactor {
        mainReactor = CalendarPostViewReactor(coordinator: coordinator)
        return mainReactor!
    }
    
    // MARK: - 달력
    private func makeCalendarViewController() -> CalendarViewController {
        return .init(reactor: makeCalendarViewReactor())
    }
    
    private func makeCalendarViewReactor() -> CalendarViewReactor {
        let calendarRepo = DefaultCalendarRepo(networkService: appNetworkService)
        let reactor = CalendarViewReactor(fetchCalendraDatesUseCase: makeFetchCalendarDatesUseCase(repo: calendarRepo),
                                          fetchHolidaysUseCase: makeFetchHolidaysUseCase(repo: calendarRepo),
                                          delegate: mainReactor!)
        mainReactor?.calendarCommands = reactor
        return reactor
    }
    
    private func makeFetchCalendarDatesUseCase(repo: CalendarRepo) -> FetchAllPlanDate {
        return FetchAllPlanDateUseCase(repo: repo)
    }
    
    private func makeFetchHolidaysUseCase(repo: CalendarRepo) -> FetchHolidays {
        return FetchHolidaysUseCase(repo: repo)
    }
    
    // MARK: - 일정 리스트
    private func makeScheduleListViewController() -> PostListViewController {
        return PostListViewController(reactor: makeScheduleListReactor())
    }
    
    private func makeScheduleListReactor() -> PostListViewReactor {
        let reactor = PostListViewReactor(
            fetchMonthlyPostUseCase: makeFetchMonthlyPlanUseCase(),
            delegate: mainReactor!
        )
        mainReactor?.scheduleListCommands = reactor
        return reactor
    }
    
    private func makeFetchMonthlyPlanUseCase() -> FetchMonthlyPost {
        return FetchMonthlyPostUseCase(
            repo: DefaultCalendarRepo(networkService: appNetworkService)
        )
    }
}

// MARK: - Flow
extension CalendarSceneDIContainer {
    // MARK: - 일정 상세
    func makePlanDetailFlowCoordinator(postId: Int, type: PostType) -> BaseCoordinator {
        let planDetailDI = PostDetailSceneDIContainer(appNetworkService: appNetworkService,
                                                      commonFactory: commonViewFactory,
                                                      type: type,
                                                      id: postId)
        return planDetailDI.makePostDetailCoordinator()
    }
}

