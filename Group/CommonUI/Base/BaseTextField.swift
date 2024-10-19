//
//  DefaultTextField.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit
import RxSwift
import RxCocoa

class BaseTextField: UITextField {

    init(configure: UIConstructive) {
        super.init(frame: .zero)
        backgroundColor = .clear
        setType(configure)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setType(_ setValues: UIConstructive) {
        placeholder = setValues.itemConfig.text
        font = setValues.itemConfig.font
        textColor = setValues.itemConfig.color
        tintColor = setValues.itemConfig.color
    }
    
    func updateLayout() {
        self.setNeedsLayout()
    }
}
extension Reactive where Base: BaseTextField {
    var isResign: Binder<Bool> {
        return Binder(self.base) { textField, isResign in
            if isResign {
                textField.resignFirstResponder()
            }
        }
    }
}
