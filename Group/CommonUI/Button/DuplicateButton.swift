//
//  DupulicateButton.swift
//  Group
//
//  Created by CatSlave on 11/11/24.
//

import UIKit
import RxSwift

final class DuplicateButton: BaseButton {
    
    override init() {
        super.init()
        setupDefault()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDefault() {
        self.rx.isEnabled.onNext(false)
    }
    
    fileprivate func updateColor(_ isEnabled: Bool) {
        print(#function, #line, "isEnabled : \(isEnabled)" )
        configuration?.background.backgroundColor = isEnabled ?
        ColorStyle.App.secondary :
        ColorStyle.App.secondary.withAlphaComponent(0.2)
    }
}

extension Reactive where Base: DuplicateButton {
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { btn, isEnabled in
            print(#function, #line, "reactive" )
            btn.isEnabled = isEnabled
            btn.updateColor(isEnabled)
        }
    }
}


