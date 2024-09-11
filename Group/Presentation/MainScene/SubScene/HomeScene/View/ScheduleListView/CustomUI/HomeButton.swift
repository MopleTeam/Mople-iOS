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
    
    private let buttonImage = UIImageView()
    
    private let buttonTitle:UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var allStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [buttonTitle, buttonImage])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .trailing
        sv.spacing = 4
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        sv.isUserInteractionEnabled = false
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
        let config = setValue.itemConfig
        buttonImage.image = config.image
        buttonTitle.text = config.text
        buttonTitle.font = config.font
        buttonTitle.textColor = config.color
        addSubview(allStackView)
        
        allStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttonTitle.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(16)
        }
    }
    
    private func setRadius(radius: CGFloat?) {
        guard let radius = radius else { return }
        
        clipsToBounds = true
        layer.cornerRadius = radius
    }
}


