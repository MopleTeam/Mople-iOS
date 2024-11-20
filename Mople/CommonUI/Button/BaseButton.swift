//
//  DefaultButton.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit
import RxSwift

class BaseButton: UIButton {
    
    enum ContentAlignment {
        case fill
        case left
    }
    
    var title: String? {
        get { configuration?.title }
        set { configuration?.title = newValue }
    }
    
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
    
    public func setButtonAlignment(_ alignment: ContentAlignment) {
        configuration?.contentInsets = .zero
        switch alignment {
        case .fill:
            self.contentHorizontalAlignment = .fill
        case .left:
            self.contentHorizontalAlignment = .left
        }
    }
    
    public func setLayoutMargins(inset: NSDirectionalEdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)) {
        self.configuration?.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
    }
    public func setImage(image: UIImage?,
                         imagePlacement: NSDirectionalRectEdge = .trailing,
                         contentPadding: CGFloat = 0) {
        configuration?.image = image
        configuration?.imagePlacement = imagePlacement
        configuration?.imagePadding = contentPadding
        
    }
    
    public func setBgColor(_ color: UIColor?) {
        configuration?.background.backgroundColor = color
    }
    
    public func setTitle(text: String? = nil,
                         font: UIFont? = nil,
                         color: UIColor? = nil) {
        
        configuration?.title = text
        setFont(font, color)
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
}
