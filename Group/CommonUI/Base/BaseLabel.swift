//
//  DefaultLabel.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

class BaseLabel: UILabel {

    init(backColor: UIColor? = nil,
         radius: CGFloat? = nil,
         configure: UIConstructive? = nil) {
        super.init(frame: .zero)
        
        setConfigure(configure: configure)
        setBackground(color: backColor, radius: radius)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func setConfigure(configure: UIConstructive?) {
        text = configure?.itemConfig.text
        font = configure?.itemConfig.font
        textColor = configure?.itemConfig.color
    }
}

// MARK: - 배경 적용하기
extension BaseLabel {
    func setBackground(color: UIColor?, radius: CGFloat?) {
        self.backgroundColor = color ?? .clear
        self.clipsToBounds = true
        self.layer.cornerRadius = radius ?? 0
    }
}

