//
//  DefaultInputTextField.swift
//  Mople
//
//  Created by CatSlave on 11/20/24.
//

import UIKit
import RxSwift
import RxCocoa

final class LabeledTextField: UIView {
    
    enum ViewMode {
        case left
        case right
    }
    
    // MARK: - Reactive
    public var rx_text: ControlProperty<String?> {
        return inputTextField.rx.text
    }
    
    public var rx_editing: ControlEvent<Void> {
        return inputTextField.rx.controlEvent(.editingChanged)
    }
    
    public var rx_Resign: Binder<Bool> {
        return inputTextField.rx.isResign
    }
    
    public var text: String? {
        return inputTextField.text
    }
    
    private var maxCount: Int?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._01
        label.textAlignment = .left
        return label
    }()
    
    private let textFieldContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.BG.input
        view.layer.cornerRadius = 8
        return view
    }()

    // 플레이스 홀더 셋팅
    private let inputTextField: UITextField = {
        let textField = UITextField()
        textField.font = FontStyle.Body1.regular
        textField.textColor = ColorStyle.Gray._01
        textField.tintColor = ColorStyle.Gray._01
        return textField
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, textFieldContainer])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(title: String,
         placeholder: String?,
         maxCount: Int) {
        super.init(frame: .zero)
        self.maxCount = maxCount
        initialsetup(title, placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialsetup(_ title: String,_ placeholder: String?) {
        setTitle(title)
        setPlaceholder(placeholder)
        setTextfield()
        setupUI()
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        self.textFieldContainer.addSubview(inputTextField)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        
        textFieldContainer.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        inputTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(16)
            make.verticalEdges.equalToSuperview()
        }
    }
    
    private func setTextfield() {
        inputTextField.delegate = self
    }
}

extension LabeledTextField : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text, let maxCount else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= maxCount
    }
}

// MARK: - 텍스트 설정
extension LabeledTextField {
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    /// 텍스트 필드 플레이스 홀더 설정
    private func setPlaceholder(_ text: String?,
                               _ textColor: UIColor = ColorStyle.Gray._05) {
        guard let text else { return }
        
        inputTextField.attributedPlaceholder = NSAttributedString(string:text,
                                                                  attributes: [NSAttributedString.Key.foregroundColor: textColor])
    }
}

// MARK: - 외부 설정
extension LabeledTextField {
    
    public func setInputTextField(view: UIView, mode: ViewMode) {
        switch mode {
        case .left:
            self.inputTextField.leftView = view
            self.inputTextField.leftViewMode = .always
        case .right:
            self.inputTextField.rightView = view
            self.inputTextField.rightViewMode = .always
        }
    }
}

