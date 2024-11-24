//
//  DefaultButton.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit
import RxSwift

class BaseButton: UIButton {

    var title: String? {
        get { configuration?.title }
        set { configuration?.title = newValue }
    }
    
    private(set) var enabledBackColor: UIColor?
    private(set) var disabledBackColor: UIColor?
    
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
    
    public func setBgColor(_ color: UIColor?, disabledColor: UIColor? = nil) {
        configuration?.background.backgroundColor = color
        enabledBackColor = color
        disabledBackColor = disabledColor
    }
    
    public func setTitle(text: String? = nil,
                         font: UIFont? = nil,
                         color: UIColor? = nil) {
        
        configuration?.title = text
        setFont(font, color)
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
    
    fileprivate func updateEnabledColor(_ isEnabled: Bool) {
        guard let enabledBackColor, let disabledBackColor else { return }
        configuration?.background.backgroundColor = isEnabled ? enabledBackColor : disabledBackColor
    }
}

extension Reactive where Base: BaseButton {
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { button, isEnabled in
            button.isEnabled = isEnabled
            button.updateEnabledColor(isEnabled)
        }
    }
}
