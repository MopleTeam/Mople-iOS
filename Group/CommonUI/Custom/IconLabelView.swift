//
//  InfoLabel.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import SnapKit

final class IconLabelView: UIView {
    
    private var configure: UIConstructive
    private var iconSize: CGFloat
    
    private let imageContainerView = UIView()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = configure.itemConfig.image
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var infoLabel: BaseLabel = {
        let label = BaseLabel(configure: configure)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainerView, infoLabel])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        sv.spacing = 4
        return sv
    }()
    
    init(iconSize: CGFloat,
         configure: UIConstructive) {
        self.configure = configure
        self.iconSize = iconSize
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        self.imageContainerView.addSubview(imageView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageContainerView.snp.makeConstraints { make in
            make.width.equalTo(iconSize)
            make.height.equalToSuperview()
        }
//        
        imageView.snp.makeConstraints { make in
            make.centerX.top.equalToSuperview()
            make.size.equalTo(iconSize)
        }
    }
    
    public func setText(_ text: String) {
        self.infoLabel.text = text
    }
}
