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
    
    // MARK: - Flow
    func makePlanDetailFlowCoordinator(planId: Int) -> BaseCoordinator
}

final class CalendarSceneDIContainer {
    private let appNetworkService: AppNetworkService
    private let commonFactory: CommonSceneFactory

    init(appNetworkService: AppNetworkService,
         commonFactory: CommonSceneFactory) {
        self.appNetworkService = appNetworkService
        self.commonFactory = commonFactory
    }
    
    func makeCalendarFlowCoordinator() -> CalendarFlowCoordinator {
        let navi = AppNaviViewController(type: .main)
        navi.tabBarItem = .init(title: TextStyle.Tabbar.group,
                                image: .people,
                                selectedImage: nil)
        return .init(navigationController: navi,
                     dependency: self)
    }
}

extension CalendarSceneDIContainer: CalendarSceneDependencies {
    // MARK: - 캘린더
    func makeCalendarScheduleViewcontroller() -> CalendarScheduleViewController {
        return CalendarScheduleViewController(title: TextStyle.Tabbar.calendar,
                                              reactor: makeCalendarViewReactor())
    }

    private func makeCalendarViewReactor() -> CalendarViewReactor {
        return CalendarViewReactor(fetchUseCase: FetchScheduleMock())
    }
    
    // MARK: - 일정 상세 뷰
    func makePlanDetailFlowCoordinator(planId: Int) -> BaseCoordinator {
        return commonFactory.makePlanDetailCoordinator(planId: planId)
    }
}
