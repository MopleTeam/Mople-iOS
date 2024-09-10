//
//  Alertable.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import UIKit


protocol Alertable: AnyObject { }

extension Alertable where Self: UIViewController {
    
    func showAlert(
        title: String = "",
        message: String,
        preferredStyle: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
    
    
    func showActionSheet(
        title: String = "",
        message: String = "",
        preferredStyle: UIAlertController.Style = .actionSheet,
        actions: [UIAlertAction],
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)
        actions.forEach { alert.addAction($0) }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        self.present(alert, animated: true, completion: completion)
    }
}

extension Alertable {
    func makeAction(
        title: String,
        style: UIAlertAction.Style = .default,
        completion: (() -> Void)? = nil
    ) -> UIAlertAction {
        return .init(title: title, style: style) { _ in
            completion?()
        }
    }
}
