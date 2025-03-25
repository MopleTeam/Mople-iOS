//
//  ToastMessageManager.swift
//  Mople
//
//  Created by CatSlave on 2/21/25.
//

import UIKit
import SnapKit

final class ToastManager {
    
    static let shared = ToastManager()
    
    private let animationDuration: TimeInterval = 0.3
    
    private init() { }
    
    private var window: UIWindow? {
        UIApplication.shared.keyWindow
    }
    
    private lazy var messageLabel: IconLabel = {
        let frameY = UIScreen.getBottomSafeAreaHeight() + 56
        
        let label = IconLabel(icon: .check,
                              iconSize: .init(width: 24, height: 24),
                              frame: .init(x: 27.5,
                                           y: self.window!.frame.size.height-frameY,
                                           width: 320,
                                           height: 56))
        label.backgroundColor = ColorStyle.Toast.defaultColor.withAlphaComponent(0.8)
        label.addBlur(style: .systemUltraThinMaterialDark)
        label.setTitle(font: FontStyle.Body1.medium,
                       color: ColorStyle.Default.white)
        label.setSpacing(12)
        label.setMargin(.init(top: 16, left: 20, bottom: 16, right: 20))
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.alpha = 0
        return label
    }()
    
    public func presentToast(text: String) {
        setMessage(text)
        showToastMessage(completion: { [weak self] in
            self?.hideToastMeesage()
        })
    }
    
    private func setMessage(_ text: String) {
        messageLabel.text = text
    }
}

// MARK: - 애니메이션
extension ToastManager {
    private func showToastMessage(completion: @escaping (() -> Void)) {
        self.setToastView()
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            UIView.animate(withDuration: animationDuration,
                           animations: { [weak self] in
                self?.messageLabel.alpha = 1
                self?.window?.layoutIfNeeded()
            }, completion: { _ in
                completion()
            })
        }
    }
    
    private func hideToastMeesage() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: { [weak self] in
            guard let self else { return }
            UIView.animate(withDuration: animationDuration,
                           animations: { [weak self] in
                self?.messageLabel.alpha = 0
                self?.window?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.removeToastView()
            })
        })
    }

    private func setToastView() {
        window?.addSubview(messageLabel)
    }
    
    private func removeToastView() {
        messageLabel.removeFromSuperview()
    }
}

