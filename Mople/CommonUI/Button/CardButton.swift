//
//  HomeButton.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import SnapKit
import SwiftUI

final class CardButton: UIButton {
    
    private let buttonImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let buttonTitle: UILabel = {
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
    
    init() {
        super.init(frame: .zero)
        setupUI()
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        setRadius(radius: 12)
        backgroundColor = ColorStyle.Default.white
        buttonTitle.font = FontStyle.Title3.semiBold
        buttonTitle.textColor = ColorStyle.Gray._01
    }

    private func setupUI() {
        addSubview(allStackView)
        
        allStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        buttonTitle.snp.makeConstraints { make in
            make.width.equalToSuperview().inset(16)
        }
        
        buttonImage.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }
    
    private func setRadius(radius: CGFloat?) {
        guard let radius = radius else { return }
        
        clipsToBounds = true
        layer.cornerRadius = radius
    }
}

extension CardButton {
    public func setImage(image: UIImage?) {
        buttonImage.image = image
    }
    
    public func setTitle(text: String? = nil) {
        buttonTitle.text = text
    }
}


