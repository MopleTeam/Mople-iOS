//
//  TitleButton.swift
//  Mople
//
//  Created by CatSlave on 11/20/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LabeledButton: UIView {
    
    // MARK: - Reactive
    public var rx_tap: ControlEvent<Void> {
        return button.rx.controlEvent(.touchUpInside)
    }
    
    enum ViewMode {
        case left
        case right
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._01
        label.textAlignment = .left
        return label
    }()
    
    private let button: BaseButton = {
        let btn = BaseButton()
        btn.setButtonAlignment(.left)
        btn.setBgColor(ColorStyle.BG.input)
        btn.setRadius(8)
        btn.setLayoutMargins()
        return btn
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, button])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(title: String,
         inputText: String? = nil,
         icon: UIImage? = nil) {
        super.init(frame: .zero)
        setTitle(title)
        setDefaultText(inputText)
        setIconImage(icon)
        setupUI()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        
        button.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}


// MARK: - 텍스트 설정
extension LabeledButton {
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    /// 텍스트 필드 플레이스 홀더 설정
    private func setDefaultText(_ text: String?) {
        button.setTitle(text: text,
                     font: FontStyle.Body1.regular,
                     color: ColorStyle.Gray._05)
    }
    
    private func setIconImage(_ image: UIImage?) {
        guard let image else { return }
        button.setImage(image: image, imagePlacement: .leading, contentPadding: 16)
    }
}

// MARK: - 외부 설정
extension LabeledButton {

    public func setLayoutMargins(inset: NSDirectionalEdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)) {
        button.setLayoutMargins(inset: inset)
    }
}

