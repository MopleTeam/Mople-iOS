//
//  InteractivePopHostingController.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SwiftUI

// SwiftUI 자식 화면을 AppNaviViewController에 push할 때 사용하는 베이스.
// AppNaviViewController는 navigationBar.isHidden = true 이므로 기본 동작상
// interactivePopGestureRecognizer가 비활성/동작 불가 상태가 된다.
// 이 클래스는 viewDidAppear 시점에 명시적으로 활성화하여
// 좌측 edge swipe로 표준 pop이 동작하도록 보장한다.
//
// 사용 패턴은 TitleNaviViewController.setNavigation() 과 동일.
final class InteractivePopHostingController<Content: View>: UIHostingController<Content> {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // navi root(첫 화면)일 때는 AppTransition의 modal dismiss 제스처가 처리하므로
        // navigationController.viewControllers.count > 1 일 때만 표준 pop 동작 활성화
        guard let navi = navigationController, navi.viewControllers.count > 1 else { return }
        navi.interactivePopGestureRecognizer?.isEnabled = true
        navi.interactivePopGestureRecognizer?.delegate = nil
    }
}
