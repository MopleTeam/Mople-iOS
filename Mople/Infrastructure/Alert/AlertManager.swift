//
//  Alertable.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import UIKit

final class AlertManager {
    
    static let shared = AlertManager()
    
    private init() { }
    
    private var currentVC: UIViewController? {
        UIApplication.shared.topVC
    }
    
    func showAlert(
        title: String = "",
        message: String,
        preferredStyle: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        currentVC?.present(alert, animated: true, completion: completion)
    }
    
    
    func showActionSheet(
        title: String = "",
        message: String = "",
        preferredStyle: UIAlertController.Style = .actionSheet,
        actions: [UIAlertAction],
        cancleCompletion: ((UIAlertAction) -> Void)? = nil,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)
        actions.forEach { alert.addAction($0) }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { action in
            cancleCompletion?(action)
        }))
        currentVC?.present(alert, animated: true, completion: completion)
    }
}

extension AlertManager {
    func makeAction(title: String,
                    style: UIAlertAction.Style = .default,
                    completion: (() -> Void)? = nil) -> UIAlertAction {
        return .init(title: title, style: style) { _ in
            completion?()
        }
    }
}

struct DefaultAction {
    
    var text: String
    var tintColor: UIColor
    var bgColor: UIColor
    var completion: (() -> Void)?
    
    init(text: String = "확인",
         tintColor: UIColor = ColorStyle.Default.white,
         bgColor: UIColor = ColorStyle.App.primary,
         completion: (() -> Void)? = nil) {
        
        self.text = text
        self.completion = completion
        self.tintColor = tintColor
        self.bgColor = bgColor
    }
}

final class TestAlertManager {
    
    static let shared = TestAlertManager()
    
    private init() { }
    
    private var currentVC: UIViewController? {
        UIApplication.shared.topVC
    }
    
    func showAlert(title: String,
                   subTitle: String? = nil,
                   defaultAction: DefaultAction = .init(),
                   addAction: [DefaultAction] = []) {
        let alert = DefaultAlertControl(title: title,
                                        subTitle: subTitle,
                                        defaultAction: defaultAction,
                                        addAction: addAction)
        currentVC?.present(alert, animated: true)
    }
}
