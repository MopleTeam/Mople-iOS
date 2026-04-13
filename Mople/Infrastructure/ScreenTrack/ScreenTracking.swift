//
//  ScreenTracking.swift
//  Mople
//
//  Created by CatSlave on 4/29/25.
//

import UIKit
import FirebaseCore

protocol ScreenTrackable: UIViewController {
    var screenName: ScreenName? { get }
}

// Firebase Analytics 이벤트 로깅
// FirebaseAnalytics 모듈은 binary xcframework라 Tuist에서 직접 import 불가
// ObjC 런타임을 통해 FIRAnalytics.logEventWithName:parameters: 호출
enum ScreenTracking {

    private typealias LogEventIMP = @convention(c) (AnyClass, Selector, NSString, NSDictionary) -> Void

    static func track(with viewController: UIViewController) {
        guard let trackingView = viewController as? ScreenTrackable,
              let screenName = trackingView.screenName else { return }
        let screenClass = String(describing: type(of: viewController))

        guard let cls = NSClassFromString("FIRAnalytics") else { return }
        let sel = NSSelectorFromString("logEventWithName:parameters:")
        guard cls.responds(to: sel) else { return }

        let imp = unsafeBitCast(cls.method(for: sel)!, to: LogEventIMP.self)
        imp(cls, sel, "screen_view" as NSString, [
            "screen_name": screenName.rawValue,
            "screen_class": screenClass
        ] as NSDictionary)
    }
}
