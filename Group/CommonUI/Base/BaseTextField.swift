//
//  DefaultTextField.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

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
