//
//  DismissableHostingController.swift
//  Mople
//
//  Created by CatSlave on 4/9/26.
//

import SwiftUI
import Domain

/// present 시 push처럼 동작 + 엣지 스와이프 dismiss 지원하는 UIHostingController
/// SwiftUI 뷰를 slidePresentWithTracking으로 표시할 때 사용
final class DismissableHostingController<Content: View>: UIHostingController<Content>, DismissTansitionControllabel {
    var dismissTransition: AppTransition = .init(type: .dismiss)

    override init(rootView: Content) {
        super.init(rootView: rootView)
        // present 전에 fullScreen 설정되어야 push 애니메이션 동작
        modalPresentationStyle = .fullScreen
    }

    @MainActor @preconcurrency required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // view 로드 후 엣지 스와이프 dismiss 제스처 등록
        dismissTransition.setupDismissGesture(for: self)
    }
}
