//
//  KeyboardDismissable.swift
//  Mople
//
//  Created by CatSlave on 12/31/24.
//

import UIKit
import RxSwift

protocol KeyboardDismissable {
    var disposeBag: DisposeBag { get }
    var tapGestureShouldCancelTouchesInView: Bool { get }
    func setupTapKeyboardDismiss()
    func setupPanKeyboardDismiss()
    func dismissCompletion()
}

extension KeyboardDismissable where Self: UIViewController {
    var tapGestureShouldCancelTouchesInView: Bool { true }
    
    func dismissCompletion() { }
    
    func setupTapKeyboardDismiss() {
        let backgroundTapGesture = UITapGestureRecognizer()
        backgroundTapGesture.cancelsTouchesInView = tapGestureShouldCancelTouchesInView
        self.configureGestureDelegate(backgroundTapGesture)
        self.view.addGestureRecognizer(backgroundTapGesture)
        self.gestureBind(gestrue: backgroundTapGesture, targetState: .ended)
    }
    
    func setupPanKeyboardDismiss() {
        let backgroundPanGestrue = UIPanGestureRecognizer()
        self.configureGestureDelegate(backgroundPanGestrue)
        self.view.addGestureRecognizer(backgroundPanGestrue)
        self.gestureBind(gestrue: backgroundPanGestrue, targetState: .began)
    }
    
    private func gestureBind(gestrue: UIGestureRecognizer, targetState: UIGestureRecognizer.State) {
        gestrue.rx.event
            .asDriver()
            .filter({ $0.state == targetState })
            .drive(with: self, onNext: { vc, _ in
                vc.view.endEditing(true)
                vc.dismissCompletion()
            })
            .disposed(by: disposeBag)
    }
    
    private func configureGestureDelegate(_ gesture: UIGestureRecognizer) {
        guard let self = self as? UIGestureRecognizerDelegate else { return }
        gesture.delegate = self
    }
}
