//
//  DefaultButton.swift
//  Group
//
//  Created by CatSlave on 8/13/24.
//

import UIKit
import RxSwift

class BaseButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            let opacity: CGFloat = isEnabled ? 1 : 0.2
            self.configuration?.background.backgroundColor = self.activeColor?.withAlphaComponent(opacity)
        }
    }
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        view.color = .white
        return view
    }()
        
    
    /// 비활성화 색
    private var activeColor: UIColor?
    private var defaultTitle: String?
    
    init(backColor: UIColor? = nil,
         radius: CGFloat? = nil,
         configure: UIConstructive) {
        
        super.init(frame: .zero)
        configuration = .filled()
        self.setupUI()
        self.setBackgroundColor(color: backColor)
        self.setItemConfigrue(configure)
        self.setRadius(radius: radius)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(loadingIndicator)
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setBackgroundColor(color: UIColor?) {
        self.activeColor = color
        configuration?.background.backgroundColor = color
    }
    
    private func setItemConfigrue(_ setValues: UIConstructive) {
        let config = setValues.itemConfig
        
        defaultTitle = config.text
        configuration?.title = config.text
        configuration?.image = config.image
        
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
    
    func loading(status: Bool) {
        configuration?.showsActivityIndicator = status
        configuration?.title = status ? nil : defaultTitle
    }
}
