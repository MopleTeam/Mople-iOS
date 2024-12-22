//
//  DefaultTextField.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import UIKit
import RxSwift
import RxCocoa

final class DefaultTextField: UIView {
    
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
        textField.tintColor = ColorStyle.Gray._02
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setTextfield()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(textFieldContainer)
        self.textFieldContainer.addSubview(inputTextField)

        textFieldContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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

extension DefaultTextField : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text, let maxCount else { return true }
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= maxCount
    }
}

// MARK: - 외부 설정
extension DefaultTextField {
    
    public func setMaxTextCount(_ maxTextCount: Int?) {
        self.maxCount = maxTextCount
    }
    
    /// 텍스트 필드 플레이스 홀더 설정
    public func setPlaceholder(_ text: String?) {
        guard let text else { return }
        inputTextField.attributedPlaceholder = NSAttributedString(string:text,
                                                                  attributes: [NSAttributedString.Key.foregroundColor: ColorStyle.Gray._05])
    }
    
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
