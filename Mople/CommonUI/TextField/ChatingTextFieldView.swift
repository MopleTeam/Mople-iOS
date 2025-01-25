//
//  ChatingTextFieldView.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import UIKit
import RxSwift
import RxCocoa

final class ChatingTextFieldView: UIView {
    
    private var disposeBag = DisposeBag()
    
    fileprivate let sendButton: BaseButton = {
        let btn = BaseButton()
        btn.setImage(image: .sendArrow,
                     imagePlacement: .all)
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(20)
        btn.isEnabled = false
        return btn
    }()
    
    fileprivate let textField: DefaultTextField = {
        let textField = DefaultTextField()
        textField.setPlaceholder("댓글을 입력해주세요")
        textField.inputTextField.returnKeyType = .send
        return textField
    }()
    
    private lazy var textFieldStackview: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [textField, sendButton])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .center
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 20, bottom: 0, right: 20)
        return sv
    }()
    
    init() {
        super.init(frame: .zero)
        setLayout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.addSubview(textFieldStackview)
        
        textFieldStackview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        sendButton.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }
    
    private func bind() {
        self.textField.rx.isEditMode
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isEditing in
                vc.handlePresentSendButton(isEditing)
            })
            .disposed(by: disposeBag)
        
        self.textField.rx.text
            .compactMap { $0 }
            .map { $0.count > 0 }
            .asDriver(onErrorJustReturn: false)
            .drive(sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func handlePresentSendButton(_ isEditing: Bool) {
        self.sendButton.isHidden = !isEditing
    }
}

extension Reactive where Base: ChatingTextFieldView {
    var inputText: Observable<String?> {
        return base.textField.rx.text
    }
    
    var text: ControlProperty<String?> {
        return base.textField.inputTextField.rx.text
    }
    
    var isResign: Binder<Bool> {
        return base.textField.rx.isResign
    }
    
    var isEditMode: Observable<Bool> {
        return base.textField.rx.isEditMode
    }
    
    var sendButtonTapped: Observable<String> {
        return base.sendButton.rx.controlEvent(.touchUpInside)
            .do(onNext: { _ in
                base.textField.inputTextField.rx.isResign.onNext(true)
            })
            .map { _ in base.textField.text }
            .compactMap { $0 }
            .filter { $0.count > 0 }
    }
    
    var keyboardSendButtonTapped: Observable<String> {
        return base.textField
            .inputTextField.rx
            .controlEvent(.editingDidEndOnExit)
            .map { _ in base.textField.text }
            .compactMap { $0 }
            .filter { $0.count > 0 }
    }
}
