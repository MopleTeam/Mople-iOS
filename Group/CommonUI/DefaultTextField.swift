//
//  DefaultTextField.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

class DefaultTextField: UITextField {
    
    init(configure: UIConstructive) {
        super.init(frame: .zero)
        backgroundColor = .clear
        setType(configure)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setType(_ setValues: UIConstructive) {
        placeholder = setValues.uiConfig.text
        font = setValues.uiConfig.font
        textColor = setValues.uiConfig.color
        tintColor = setValues.uiConfig.color
    }
    
    func updateLayout() {
        self.setNeedsLayout()
    }
}
