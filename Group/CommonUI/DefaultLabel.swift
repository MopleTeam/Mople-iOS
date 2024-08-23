//
//  DefaultLabel.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

class DefaultLabel: UILabel {
    
    var isOverlapCheck: Bool = false {
        didSet {
            let color: UIColor = isOverlapCheck ? .init(hexCode: "FF3B30") : .clear
            textColor = color
        }
    }
    
    
    init(configure: TextConstructive) {
        super.init(frame: .zero)
        setType(configure)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setType(_ setValues: TextConstructive) {
        text = setValues.textConfig.text
        font = setValues.textConfig.font
        textColor = setValues.textConfig.color
    }
}
