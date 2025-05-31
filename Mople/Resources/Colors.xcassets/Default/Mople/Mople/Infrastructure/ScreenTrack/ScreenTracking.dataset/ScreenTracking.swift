//
//  ScreenTracking.swift
//  Mople
//
//  Created by CatSlave on 4/29/25.
//

import UIKit
import FirebaseAnalytics

protocol ScreenTrackable: UIViewController {
    var screenName: ScreenName? { get }
}

enum ScreenTracking {
    static func track(with viewController: UIViewController) {
        guard let trackingView = viewController as? ScreenTrackable,
              let screenName = trackingView.screenName else { return }
        let screenClass = String(describing: type(of: viewController))
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: screenName.rawValue,
            AnalyticsParameterScreenClass: screenClass
        ])
    }
}
