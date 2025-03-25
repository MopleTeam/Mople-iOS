//
//  ErrorHandlingService.swift
//  Mople
//
//  Created by CatSlave on 3/25/25.
//

import Foundation

final class DefaultErrorHandlingService {
    
    private let alertManager = TestAlertManager.shared
    private var isShowAlert: Bool = false
    
    func handleError(err: AppError) {
        guard isShowAlert == false else { return }
        isShowAlert = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            switch err {
            case .networkUnavailable, .unknown:
                showDefaultAlert(with: err)
            case .expiredToken:
                handleTokenExpired(err: err)
            default: break
            }
        }
    }
    
    private func showDefaultAlert(with err: AppError) {
        guard let title = err.info else { return }
        alertManager.showAlert(title: title,
                               defaultAction: .init(completion: { [weak self] in
            self?.isShowAlert = false
        }))
    }
    
    private func handleTokenExpired(err: AppError) {
        guard case .expiredToken = err,
              let title = err.info,
              let subTitle = err.subInfo else { return }

        alertManager.showAlert(title: title,
                               subTitle: subTitle,
                               defaultAction: .init(completion: {
            self.isShowAlert = false
            EventService.shared.post(name: .sessionExpired)
        }))
    
    }
}
