//
//  Reactive+TextField.swift
//  Group
//
//  Created by CatSlave on 11/11/24.
//

import UIKit
import RxSwift

extension Reactive where Base: UITextField {
    var isResign: Binder<Bool> {
        return Binder(self.base) { textField, isResign in
            if isResign {
                textField.resignFirstResponder()
            } else {
                textField.becomeFirstResponder()
            }
        }
    }
}
