//
//  TitleButton.swift
//  Mople
//
//  Created by CatSlave on 11/20/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LabeledButtonView: UIView {
    
    fileprivate let defaultText: String?
    
    enum ViewMode {
        case left
        case right
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    private(set) lazy var button: BaseButton = {
        let btn = BaseButton()
        btn.setButtonAlignment(.left)
        btn.setBgColor(normalColor: ColorStyle.BG.input)
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
        defaultText = inputText
        super.init(frame: .zero)
        setTitle(title)
        setText(inputText)
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
extension LabeledButtonView {
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    /// 텍스트 필드 플레이스 홀더 설정
    private func setText(_ text: String?) {
        button.setTitle(text: text,
                     font: FontStyle.Body1.regular,
                     normalColor: ColorStyle.Gray._05)
    }
    
    fileprivate func setSelectedTextText(_ text: String?) {
        button.setTitle(text: text,
                     font: FontStyle.Body1.regular,
                     normalColor: ColorStyle.Gray._02)
    }
    
    private func setIconImage(_ image: UIImage?) {
        guard let image else { return }
        button.setImage(image: image, imagePlacement: .leading, contentPadding: 16)
    }
}

// MARK: - 외부 설정
extension LabeledButtonView {

    public func setLayoutMargins(inset: NSDirectionalEdgeInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)) {
        button.setLayoutMargins(inset: inset)
    }
}

extension Reactive where Base: LabeledButtonView {
    var selectedText: Binder<String?> {
        return Binder(self.base) { button, text in
            button.setSelectedTextText(text ?? button.defaultText)
        }
    }
}

