//
//  DefaultLabel.swift
//  Group
//
//  Created by CatSlave on 8/20/24.
//

import UIKit

final class DefaultLabel: UILabel {
    
    var isOverlapCheck: Bool = false {
        didSet {
            let color: UIColor = isOverlapCheck ? .init(hexCode: "FF3B30") : .clear
            textColor = color
        }
    }
    
    var padding: UIEdgeInsets
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: padding))
    }
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + padding.left + padding.right,
                      height: size.height + padding.bottom + padding.top)
    }
    
    init(backColor: UIColor? = nil,
         radius: CGFloat? = nil,
         padding: UIEdgeInsets = .zero,
         itemConfigure: UIConstructive) {
        self.padding = padding
        super.init(frame: .zero)
        setType(itemConfigure)
        setBackground(color: backColor, radius: radius)
    }
    
    required init?(coder: NSCoder) {
        self.padding = .zero
        super.init(coder: coder)
    }
    
    private func setType(_ setValues: UIConstructive) {
        text = setValues.uiConfig.text
        font = setValues.uiConfig.font
        textColor = setValues.uiConfig.color
    }
}

// MARK: - 배경 적용하기
extension DefaultLabel {
    func setBackground(color: UIColor?, radius: CGFloat?) {
        self.backgroundColor = color ?? .clear
        self.clipsToBounds = true
        self.layer.cornerRadius = radius ?? 0
    }
}
