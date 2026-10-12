//
//  InteractivePopHostingController.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SwiftUI

// SwiftUI 자식 화면을 AppNaviViewController에 push할 때 사용하는 베이스.
//
// 두 가지 책임:
//
// 1) Edge swipe pop 활성화
//    AppNaviViewController는 navigationBar.isHidden = true 이므로 기본 동작상
//    interactivePopGestureRecognizer가 비활성/동작 불가 상태가 된다.
//    viewDidAppear 시점에 명시적으로 활성화하여 좌측 edge swipe로 표준 pop이 동작하도록 보장한다.
//
// 2) 화면 탭 시 키보드 dismiss
//    SwiftUI의 .background + .onTapGesture는 자식(TextEditor 등)이 차지한 영역에서는
//    이벤트가 안 잡혀서 간헐적으로 동작하지 않는 문제가 있다.
//    UIKit gesture recognizer를 root view에 달면 더 신뢰성 있게 입력 외 영역의 탭을
//    잡을 수 있다. cancelsTouchesInView = false라 SwiftUI Button 등 컨트롤은 함께 동작.
//    delegate로 UITextView/UITextField 위 탭은 제외(해당 입력 컴포넌트의 포커싱 방해 방지).
// 제네릭 클래스는 @objc 프로토콜 채택을 extension에 두지 못해 본체에서 UIGestureRecognizerDelegate를 채택.
final class InteractivePopHostingController<Content: View>: UIHostingController<Content>, UIGestureRecognizerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDismissKeyboardTap()
    }

    // 입력 컴포넌트 위 탭은 키보드 dismiss 비활성 — 해당 컴포넌트가 포커스/커서 처리를 정상 수행하도록.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        guard let touchedView = touch.view else { return true }
        if touchedView is UITextView { return false }
        if touchedView is UITextField { return false }
        return true
    }

    private func setupDismissKeyboardTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismissKeyboardTap))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }

    @objc private func handleDismissKeyboardTap() {
        view.endEditing(true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // navi root(첫 화면)일 때는 AppTransition의 modal dismiss 제스처가 처리하므로
        // navigationController.viewControllers.count > 1 일 때만 표준 pop 동작 활성화
        guard let navi = navigationController, navi.viewControllers.count > 1 else { return }
        navi.interactivePopGestureRecognizer?.isEnabled = true
        navi.interactivePopGestureRecognizer?.delegate = nil
    }
}

