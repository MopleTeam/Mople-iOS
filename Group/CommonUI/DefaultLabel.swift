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
    
    
    init(backColor: UIColor? = nil,
         radius: CGFloat? = nil,
         itemConfigure: UIConstructive) {
        super.init(frame: .zero)
        setType(itemConfigure)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setType(_ setValues: UIConstructive) {
        text = setValues.uiConfig.text
        font = setValues.uiConfig.font
        textColor = setValues.uiConfig.color
    }
}
