//
//  DefaultInputTextField.swift
//  Mople
//
//  Created by CatSlave on 11/20/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LabeledTextFieldView: UIView {
    
    enum ViewMode {
        case left
        case right
    }
    
    public var text: String? {
        get {
            return textField.text
        } set {
            textField.text = newValue
        }
    }
        
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._01
        label.textAlignment = .left
        return label
    }()
    
    private(set) lazy var textField = DefaultTextField()

    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, textField])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(title: String,
         placeholder: String?,
         maxTextCount: Int) {
        super.init(frame: .zero)
        setMaxCount(maxTextCount)
        initialsetup(title, placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialsetup(_ title: String,_ placeholder: String?) {
        setTitle(title)
        setPlaceHolder(text: placeholder)
        setupUI()
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
}

// MARK: - 텍스트 설정
extension LabeledTextFieldView {
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    private func setPlaceHolder(text: String?) {
        self.textField.setPlaceholder(text)
    }
    
    private func setMaxCount(_ maxCount: Int) {
        self.textField.setMaxTextCount(maxCount)
    }
}

// MARK: - 외부 설정
extension LabeledTextFieldView {
    
    public func setInputTextField(view: UIView, mode: DefaultTextField.ViewMode) {
        self.textField.setInputTextField(view: view, mode: mode)
    }
}
