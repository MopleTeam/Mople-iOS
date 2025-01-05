//
//  DefaultButton.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit
import RxSwift
import RxCocoa

class BaseButton: UIButton {

    var title: String? {
        get { configuration?.title }
        set { configuration?.title = newValue }
    }
    
    override var isEnabled: Bool {
        didSet {
            self.setEnabled(isEnabled)
        }
    }
    
    private var defaultFont: UIFont?
    private var enabledBackColor: UIColor?
    private var disabledBackColor: UIColor?
    private var normalTextColor: UIColor?
    private var selectedTextColor: UIColor?
    
    init() {
        super.init(frame: .zero)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        configuration = .filled()
        setBgColor(.clear)
    }
}

extension BaseButton {
    
    public func setButtonAlignment(_ alignment: UIControl.ContentHorizontalAlignment) {
        self.contentHorizontalAlignment = alignment
    }
    
    public func setLayoutMargins(inset: NSDirectionalEdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)) {
        self.configuration?.contentInsets = inset
    }
    public func setImage(image: UIImage?,
                         imagePlacement: NSDirectionalRectEdge = .trailing,
                         contentPadding: CGFloat = 0) {
        configuration?.image = image
        configuration?.imagePlacement = imagePlacement
        configuration?.imagePadding = contentPadding
        
    }
    
    public func setBgColor(_ color: UIColor?,
                           disabledColor: UIColor? = nil) {
        configuration?.background.backgroundColor = color
        enabledBackColor = color
        disabledBackColor = disabledColor
    }
    
    public func setTitle(text: String? = nil,
                         font: UIFont? = nil,
                         normalColor: UIColor? = nil,
                         selectedColor: UIColor? = nil) {
        configuration?.title = text
        setFont(font, normalColor)
        self.defaultFont = font
        self.normalTextColor = normalColor
        self.selectedTextColor = selectedColor
    }
    
    public func setRadius(_ radius: CGFloat) {
        configuration?.background.cornerRadius = radius
    }
    
    private func setFont(_ font: UIFont?,_ color: UIColor?) {
        let transformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = color
            outgoing.font = font
            return outgoing
        }
        configuration?.titleTextAttributesTransformer = transformer
    }
    
    private func setEnabled(_ isEnabled: Bool) {
        guard let enabledBackColor, let disabledBackColor else { return }
        configuration?.background.backgroundColor = isEnabled ? enabledBackColor : disabledBackColor
    }
}

extension BaseButton {
    public func updateTextColor(isSelected: Bool) {
        let changeColor = isSelected ? selectedTextColor : normalTextColor
        setFont(defaultFont, changeColor)
    }
}


