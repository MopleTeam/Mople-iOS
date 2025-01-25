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
    
    enum DefaultStyle {
        case cancle, check
        
        var text: String {
            switch self {
            case .cancle: "취소"
            case .check: "확인"
            }
        }
    }
    
    var text: String
    var completion: (() -> Void)?
    var tintColor: UIColor = ColorStyle.Gray._01
    var bgColor: UIColor = ColorStyle.App.tertiary
    
    static func defaultButton(style: DefaultStyle,
                              completion: (() -> Void)? = nil) -> Self {
        return .init(text: style.text,
                     completion: completion,
                     tintColor: ColorStyle.Gray._01,
                     bgColor: ColorStyle.App.tertiary)
    }
}

final class TestAlertManager {
    
    static let shared = TestAlertManager()
    
    private init() { }
    
    private var currentVC: UIViewController? {
        UIApplication.shared.topVC
    }
    
    func showAlert(title: String,
                   subTitle: String?,
                   defaultAction: DefaultAction = .defaultButton(style: .cancle),
                   addAction: [DefaultAction]) {
        let alert = DefaultAlertControl(title: title,
                                        subTitle: subTitle,
                                        defaultAction: defaultAction,
                                        addAction: addAction)
        currentVC?.present(alert, animated: true)
    }
}
