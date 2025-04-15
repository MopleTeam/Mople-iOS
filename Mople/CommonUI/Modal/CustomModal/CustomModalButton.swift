//
//  CustomModalSelectView.swift
//  Mople
//
//  Created by CatSlave on 4/15/25.
//

import UIKit
import SnapKit

final class CustomModalButton: UIView {
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let textLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = ColorStyle.Gray._02
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageView, textLabel])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    init(image: UIImage,
         title: String) {
        super.init(frame: .zero)
        setupUI()
        setContent(image: image, title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview().inset(20)
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(28)
        }
    }
    
    private func setContent(image: UIImage,
                            title: String) {
        imageView.image = image
        textLabel.text = title
    }
}
