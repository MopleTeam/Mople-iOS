//
//  RouteType.swift
//  Group
//
//  Created by CatSlave on 10/14/24.
//

import UIKit

enum Route {
    case home
    case group
    case calendar
    case profile
    
    var type: UIViewController.Type {
        switch self {
        case .home:
            return HomeViewController.self
        case .group:
            return GroupListViewController.self
        case .calendar:
            return CalendarScheduleViewController.self
        case .profile:
            return SetupViewController.self
        }
    }
}
