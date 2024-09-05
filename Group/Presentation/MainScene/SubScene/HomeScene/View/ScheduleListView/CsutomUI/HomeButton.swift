//
//  HomeButton.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import SnapKit
import SwiftUI

final class HomeButton: UIButton {
    
    private let buttonImage: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private let buttonTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var allStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [buttonImage, buttonTitle])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .leading
        sv.spacing = 26
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return sv
    }()
    
    init(backColor: UIColor? = nil,
         radius: CGFloat? = nil,
         itemConfigure: UIConstructive) {
        
        super.init(frame: .zero)
        setBackGroundColor(backColor)
        setRadius(radius: radius)
        setUI(itemConfigure)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setBackGroundColor(_ color: UIColor?) {
        backgroundColor = color
    }
    
    private func setUI(_ setValue: UIConstructive) {
        let config = setValue.uiConfig
        buttonImage.image = config.image
        buttonTitle.text = config.text
        buttonTitle.font = config.font
        addSubview(allStackView)
        
        allStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setRadius(radius: CGFloat?) {
        guard let radius = radius else { return }
        
        clipsToBounds = true
        layer.cornerRadius = radius
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct MyYellowButtonPreview: PreviewProvider{
    static var previews: some View {
        UIViewPreview {
            let button = HomeButton(backColor: .systemYellow,
                                    radius: 5,
                                    itemConfigure: AppDesign.Home.makeGroup)
            return button
        }
    }
}
#endif
