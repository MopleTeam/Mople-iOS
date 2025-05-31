//
//  AppNavigationController.swift
//  Mople
//
//  Created by CatSlave on 1/12/25.
//

import UIKit

final class AppNaviViewController: UINavigationController, TransitionControllable {
    
    enum NaviType {
        case main
        case sub
    }
    
    private let type: NaviType
    
    // MARK: - Transition
    lazy var presentTransition: AppTransition = .init(type: .present)
    lazy var dismissTransition: AppTransition = .init(type: .dismiss)

    init(type: NaviType = .sub) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
        initialSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "Path : # 네비 삭제 ")
    }
    
    private func initialSetup() {
        self.navigationBar.isHidden = true
        guard type == .sub else { return }
        setupTransition()
    }
    
    public func setupDismissCompletion(completion: (() -> Void)?) {
        dismissTransition.setDismissGestureCompletion(completion: completion)
    }
}

extension AppNaviViewController {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissTransition
    }
}

