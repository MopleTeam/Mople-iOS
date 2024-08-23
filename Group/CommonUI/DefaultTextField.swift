//
//  DefaultTextField.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

class DefaultTextField: UITextField {
    
    init(configure: TextConstructive) {
        super.init(frame: .zero)
        backgroundColor = .clear
        setType(configure)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setType(_ setValues: TextConstructive) {
        placeholder = setValues.textConfig.text
        font = setValues.textConfig.font
        textColor = setValues.textConfig.color
        tintColor = setValues.textConfig.color
    }
}
