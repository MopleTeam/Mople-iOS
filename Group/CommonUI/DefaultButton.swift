//
//  DefaultButton.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit

class DefaultButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            let opacity: CGFloat = isEnabled ? 1 : 0.2
            self.configuration?.background.backgroundColor = self.backColor?.withAlphaComponent(opacity)
        }
    }
        
    private var backColor: UIColor?
    
    init(backColor: UIColor? = nil,
         radius: CGFloat? = nil,
         textConfigure: TextConstructive) {
        
        super.init(frame: .zero)
        configuration = .filled()
        self.defaultBackgroundColor(color: backColor)
        self.defaultTitleSetup(textConfigure)
        self.setRadius(radius: radius)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func defaultBackgroundColor(color: UIColor?) {
        self.backColor = color
        configuration?.background.backgroundColor = color
    }
    
    private func defaultTitleSetup(_ setValues: TextConstructive) {
        let config = setValues.textConfig
        
        configuration?.title = config.text
        
        let transformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.foregroundColor = config.color
            outgoing.font = config.font
            return outgoing
        }
        
        configuration?.titleTextAttributesTransformer = transformer
    }
    
    private func setRadius(radius: CGFloat?) {
        guard let radius = radius else { return }
        
        clipsToBounds = true
        layer.cornerRadius = radius
    }
}
