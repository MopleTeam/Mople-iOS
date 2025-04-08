//
//  Alertable.swift
//  Group
//
//  Created by CatSlave on 8/29/24.
//

import UIKit

//final class AlertManager {
//    
//    static let shared = AlertManager()
//    
//    private init() { }
//    
//    private var currentVC: UIViewController? {
//        UIApplication.shared.topVC
//    }
//    
//    func showAlert(
//        title: String = "",
//        message: String,
//        preferredStyle: UIAlertController.Style = .alert,
//        completion: (() -> Void)? = nil
//    ) {
//        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
//        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
//        currentVC?.present(alert, animated: true, completion: completion)
//    }
//    
//    
//    func showActionSheet(
//        title: String = "",
//        message: String = "",
//        preferredStyle: UIAlertController.Style = .actionSheet,
//        actions: [UIAlertAction],
//        cancleCompletion: ((UIAlertAction) -> Void)? = nil,
//        completion: (() -> Void)? = nil
//    ) {
//        let alert = UIAlertController(title: nil, message: nil, preferredStyle: preferredStyle)
//        actions.forEach { alert.addAction($0) }
//        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { action in
//            cancleCompletion?(action)
//        }))
//        currentVC?.present(alert, animated: true, completion: completion)
//    }
//}
//
//extension AlertManager {
//    func makeAction(title: String,
//                    style: UIAlertAction.Style = .default,
//                    completion: (() -> Void)? = nil) -> UIAlertAction {
//        return .init(title: title, style: style) { _ in
//            completion?()
//        }
//    }
//}

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

final class AlertManager {
    
    static let shared = AlertManager()
    
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
        self.showAlert(title: "요청에 실패했습니다.\n잠시 후 다시 시도해주세요.",
                       defaultAction: .init(completion: completion))
    }
    
    // MARK: - Midnight Handling
    func showDateErrorMessage(err: DateTransitionError,
                              completion: (() -> Void)? = nil) {
        let action = DefaultAction(completion: {
            EventService.shared.post(name: .midnightUpdate)
            completion?()
        })
        
        self.showAlert(title: err.info,
                       subTitle: err.subInfo,
                       defaultAction: action)
    }
    
    // MARK: - NoResponse Type Handling
    func showResponseErrorMessage(err: ResponseError,
                                 completion: (() -> Void)? = nil) {
        guard case .noResponse(let type) = err else { return }
        
        let action = DefaultAction(completion: { [weak self] in
            self?.handleDeletePost(type: type)
            completion?()
        })
        
        self.showAlert(title: err.info,
                       defaultAction: action)
    }
    
    private func handleDeletePost(type: ResponseType) {
        switch type {
        case let .meet(id):
            EventService.shared.postItem(MeetPayload.deleted(id: id), from: self)
        case let .plan(id):
            EventService.shared.postItem(PlanPayload.deleted(id: id), from: self)
        case let .review(id):
            EventService.shared.postItem(ReviewPayload.deleted(id: id), from: self)
        }
    }
}
