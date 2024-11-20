//
//  CompleteButton.swift
//  Group
//
//  Created by CatSlave on 11/11/24.
//

import UIKit
import RxSwift

final class CompletionButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        self.rx.isEnabled.onNext(false)
        layer.cornerRadius = 8
        titleLabel?.font = FontStyle.Title3.semiBold
        titleLabel?.textColor = ColorStyle.Default.white
    }
    
    fileprivate func updateColor(_ isEnabled: Bool) {
        backgroundColor = isEnabled ? ColorStyle.App.primary : ColorStyle.Primary.disable
    }
}

extension Reactive where Base: CompletionButton {
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { button, isEnabled in
            button.isEnabled = isEnabled
            button.updateColor(isEnabled)
        }
    }
}
