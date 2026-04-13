//
//  TitleButton.swift
//  Mople
//
//  Created by CatSlave on 11/20/24.
//

import UIKit
import Domain
import RxSwift
import RxCocoa

final class LabeledButton: UIView {
    
    fileprivate let defaultText: String?
    
    enum ViewMode {
        case left
        case right
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = .text01
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private lazy var optionLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.regular
        label.textColor = .text04
        label.text = "(선택)"
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private(set) lazy var button: BaseButton = {
        let btn = BaseButton()
        btn.setButtonAlignment(.left)
        btn.setBgColor(normalColor: .bgInput,
                       disabledColor: .inputDisable)
        btn.setRadius(8)
        btn.setLayoutMargins()
        return btn
    }()
    
    private lazy var topSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel])
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [topSV, button])
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
extension LabeledButton {
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    /// 텍스트 필드 플레이스 홀더 설정
    fileprivate func setText(_ text: String?) {
        button.setTitle(text: text,
                        font: FontStyle.Body1.regular,
                        normalColor: .text04)
    }
    
    fileprivate func setSelectedTextText(_ text: String?) {
        button.setTitle(text: text,
                        font: FontStyle.Body1.regular,
                        normalColor: .text01)
    }
    
    private func setIconImage(_ image: UIImage?) {
        guard let image else { return }
        button.setImage(image: image, imagePlacement: .leading, contentPadding: 16)
    }
    
    public func setOptionLabel() {
        topSV.addArrangedSubview(optionLabel)
    }
}

extension Reactive where Base: LabeledButton {
    var selectedText: Binder<String?> {
        return Binder(self.base) { button, text in
            if let text, !text.isEmpty {
                button.setSelectedTextText(text)
            } else {
                button.setText(button.defaultText)
            }
        }
    }
    
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { button, enabled in
            button.button.isEnabled = enabled
        }
    }
}


