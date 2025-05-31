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
            setEnabledColor(isEnabled)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            setHighlightedColor(isHighlighted)
        }
    }
    
    // MARK: - Font Save
    private var defaultFont: UIFont?
    
    // MARK: - TextColor Save
    private var normalTextColor: UIColor?
    private var selectedTextColor: UIColor?
    
    // MARK: - BackColor
    private var normalBackColor: UIColor?
    private var selectedBackColor: UIColor?
    private var disabledBackColor: UIColor?
    private var highlightBackColor: UIColor?
    
    // MARK: - LifeCycle
    init(configuration: Configuration = .filled()) {
        super.init(frame: .zero)
        initialSetup(with: configuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup(with configuration: Configuration) {
        self.configuration = configuration
        setBgColor(normalColor: .clear)
    }
    
    private func setBackgoundColor(_ color: UIColor?) {
        configuration?.background.backgroundColor = color
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
    
    private func setEnabledColor(_ isEnabled: Bool) {
        guard let normalBackColor, let disabledBackColor else { return }
        let color = isEnabled ? normalBackColor : disabledBackColor
        setBackgoundColor(color)
    }
    
    private func setHighlightedColor(_ isHighlighted: Bool) {
        guard let highlightBackColor else { return }
        let color = isHighlighted ? highlightBackColor : normalBackColor
        setBackgoundColor(color)
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
    
    public func setBgColor(normalColor: UIColor?,
                           selectedColor: UIColor? = nil,
                           disabledColor: UIColor? = nil,
                           highlightColor: UIColor? = nil) {
        setBackgoundColor(normalColor)
        normalBackColor = normalColor
        selectedBackColor = selectedColor
        disabledBackColor = disabledColor
        highlightBackColor = highlightColor
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
}

extension BaseButton {
    public func updateSelectedTextColor(isSelected: Bool) {
        let changeColor = isSelected ? selectedTextColor : normalTextColor
        setFont(defaultFont, changeColor)
    }
    
    public func updateSelectedBackColor(isSelected: Bool) {
        let changeColor = isSelected ? selectedBackColor : normalBackColor
        setBackgoundColor(changeColor)
    }
}


