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

// MARK: - 에러 알림창 표시 및 포스팅
extension TestAlertManager {
    // MARK: - 에러처리
    func showErrorAlert(err: Error,
                        completion: (() -> Void)? = nil) {
        switch err {
        case let err as ResponseError:
            showResposeErrorMessage(err: err,
                                    completion: completion)
        case let err as DateTransitionError:
            showDateErrorMessage(err: err,
                                 completion: completion)
        default:
            self.showAlert(title: "요청에 실패했습니다.")
        }
    }
    
    private func showDateErrorMessage(err: DateTransitionError,
                                      completion: (() -> Void)?) {
        let action = DefaultAction(completion: {
            EventService.shared.post(name: .midnightUpdate)
            completion?()
        })
        
        self.showAlert(title: err.info,
                               subTitle: err.subInfo,
                               defaultAction: action)
    }
    
    private func showResposeErrorMessage(err: ResponseError,
                                         completion: (() -> Void)?) {
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
