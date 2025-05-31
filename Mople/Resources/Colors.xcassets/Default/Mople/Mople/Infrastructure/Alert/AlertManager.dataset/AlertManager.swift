//
//  Alertable.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import UIKit

struct DefaultAlertAction {
    
    let text: String
    let tintColor: UIColor
    let bgColor: UIColor
    let completion: (() -> Void)?
    
    init(text: String = L10n.check,
         textColor: UIColor = .defaultWhite,
         bgColor: UIColor = .appPrimary,
         completion: (() -> Void)? = nil) {
        
        self.text = text
        self.completion = completion
        self.tintColor = textColor
        self.bgColor = bgColor
    }
}

final class AlertManager {
    
    static let shared = AlertManager()
    
    private init() { }
    
    private var currentVC: UIViewController? {
        UIApplication.shared.topVC
    }
    
    func showDefaultAlert(title: String,
                          subTitle: String? = nil,
                          defaultAction: DefaultAlertAction = .init(),
                          addAction: [DefaultAlertAction] = []) {
        let alert = DefaultAlertViewController(title: title,
                                               subTitle: subTitle,
                                               defaultAction: defaultAction,
                                               addAction: addAction)
        currentVC?.present(alert, animated: true)
    }
    
    func showWarningAlert(title: String,
                          subTitle: String? = nil,
                          defaultAction: DefaultAlertAction = .init(),
                          addAction: [DefaultAlertAction] = []) {
        let alert = DefaultAlertViewController(title: title,
                                               subTitle: subTitle,
                                               defaultAction: defaultAction,
                                               addAction: addAction)
        alert.setWarningImage()
        currentVC?.present(alert, animated: true)
    }
    
    
    // MARK: - 기본 시트 알림창
    func showActionSheet(
        title: String = "",
        message: String = "",
        preferredStyle: UIAlertController.Style = .actionSheet,
        actions: [UIAlertAction],
        cancleCompletion: ((UIAlertAction) -> Void)? = nil) {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)
            actions.forEach { alert.addAction($0) }
            alert.addAction(UIAlertAction(title: L10n.cancle, style: .cancel, handler: { action in
                cancleCompletion?(action)
            }))
            currentVC?.present(alert, animated: true)
        }
}

// MARK: - 액션 만들기
extension AlertManager {
    func makeAction(title: String,
                    style: UIAlertAction.Style = .default,
                    completion: (() -> Void)? = nil) -> UIAlertAction {
        return .init(title: title, style: style) { _ in
            completion?()
        }
    }
}

// MARK: - 에러 알림창 표시 및 포스팅
extension AlertManager {
    // MARK: - 에러처리
    func showDefatulErrorMessage(completion: (() -> Void)? = nil) {
        self.showWarningAlert(title: L10n.Error.default,
                              defaultAction: .init(completion: completion))
    }
    
    // MARK: - Midnight Handling
    func showDateErrorMessage(err: DateTransitionError,
                              completion: (() -> Void)? = nil) {
        let action = DefaultAlertAction(completion: {
            NotificationManager.shared.post(name: .midnightUpdate)
            completion?()
        })
        
        self.showDefaultAlert(title: err.info,
                              subTitle: err.subInfo,
                              defaultAction: action)
    }
    
    // MARK: - NoResponse Type Handling
    func showResponseErrorMessage(err: ResponseError,
                                  completion: (() -> Void)? = nil) {
        guard case .noResponse(let type) = err else { return }
        
        let action = DefaultAlertAction(completion: { [weak self] in
            self?.handleDeletePost(type: type)
            completion?()
        })
        
        self.showWarningAlert(title: err.info,
                              defaultAction: action)
    }
    
    private func handleDeletePost(type: ResponseType) {
        switch type {
        case let .meet(id):
            NotificationManager.shared.postItem(MeetPayload.deleted(id: id), from: self)
        case let .plan(id):
            NotificationManager.shared.postItem(PlanPayload.deleted(id: id), from: self)
        case let .review(id):
            NotificationManager.shared.postItem(ReviewPayload.deleted(id: id), from: self)
        }
    }
}
