//
//  ChatingTextFieldView.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ChatingTextFieldView: UIView {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let sendButtonContainer = UIView()
    
    fileprivate let sendButton: BaseButton = {
        let btn = BaseButton()
        btn.setImage(image: .sendArrow,
                     imagePlacement: .all)
        btn.setBgColor(normalColor: .appPrimary,
                       disabledColor: .disablePrimary)
        btn.setRadius(20)
        btn.isEnabled = false
        return btn
    }()
    
    fileprivate let textField: DefaultTextField = {
        let textField = DefaultTextField()
        textField.setPlaceholder(L10n.Comment.input)
        textField.inputTextField.returnKeyType = .default
        return textField
    }()
    
    public let textView: DefaultTextView = {
        let view = DefaultTextView()
        view.setPlaceholderText(text: L10n.Comment.input)
        return view
    }()
    
    private lazy var textFieldStackview: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [textView, sendButtonContainer])
        sv.axis = .horizontal
        sv.alignment = .bottom
        sv.distribution = .fill
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
        self.sendButtonContainer.addSubview(sendButton)
        
        textFieldStackview.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16).priority(.high)
            make.horizontalEdges.equalToSuperview().inset(20).priority(.high)
            make.bottom.equalToSuperview()
        }
        
        textView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(56)
        }
        
        sendButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview()
            make.leading.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
            make.size.equalTo(40)
        }
    }
    
    private func bind() {
        self.textView.rx.isEditMode
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isEditing in
                vc.handlePresentSendButton(isEditing)
            })
            .disposed(by: disposeBag)
        
        self.textView.rx.text
            .compactMap { $0 }
            .map { $0.count > 0 }
            .asDriver(onErrorJustReturn: false)
            .drive(sendButton.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    private func handlePresentSendButton(_ isEditing: Bool) {
        sendButtonContainer.isHidden = !isEditing
    }
}

extension Reactive where Base: ChatingTextFieldView {
    var sendText: Observable<String> {
        return base.sendButton.rx.controlEvent(.touchUpInside)
            .do(onNext: { _ in
                base.textView.rx.isResign.onNext(true)
            })
            .map { _ in base.textView.text }
            .compactMap { $0 }
            .filter { $0.count > 0 }
    }
}

final class DefaultTextView: UIView {
    
    // MARK: - Variables
    public var text: String? {
        get {
            return textView.text
        } set {
            textView.text = newValue
            updateTextViewHeight()
            setPlaceholder(isEmpty: newValue?.isEmpty ?? true)
        }
    }
    
    public var isPlaceHolder: Bool = true
    private var placeholderText: String?
    
    public var maxTextLine: Int = 4
    private var minHeight: CGFloat { 20 }
    private var maxHeight: CGFloat {
        let lineHeight = textView.font?.lineHeight ?? 0
        return lineHeight * CGFloat(maxTextLine)
    }
    
    
    // MARK: - Observable
    fileprivate let editingObservable: BehaviorRelay<Bool> = .init(value: false)

    // MARK: - UI Components
    fileprivate let textView: UITextView = {
        let textView = UITextView()
        textView.font = FontStyle.Body1.regular
        textView.textColor = .gray05
        textView.tintColor = .gray02
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return textView
    }()
    
    init() {
        super.init(frame: .zero)
        setLayout()
        setTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.backgroundColor = .bgInput
        self.layer.cornerRadius = 8
        self.addSubview(textView)
        
        textView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(8)
            make.verticalEdges.equalToSuperview().inset(18)
            textViewHeightConstraint = make.height.greaterThanOrEqualTo(20).constraint
        }
    }
    
    private var textViewHeightConstraint: Constraint?
    
    private func setTextView() {
        textView.delegate = self
    }
    
    public func setPlaceholderText(text: String) {
        self.textView.text = text
        self.placeholderText = text
    }
}

// MARK: - Delegate
extension DefaultTextView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        setPlaceholder(isEmpty: textView.text.isEmpty)
        editingObservable.accept(false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        setBeginInputMode()
        editingObservable.accept(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        updateTextViewHeight()
    }
}

// MARK: - Helper
extension DefaultTextView {
    func updateTextViewHeight() {
        // 높이 제한 없이 텍스트뷰가 필요로 하는 만큼 계산
        let fittingSize = CGSize(width: textView.frame.width,
                                 height: .greatestFiniteMagnitude)
        let expectedSize = textView.sizeThatFits(fittingSize)
        
        // max height와 텍스트뷰 최대 높이 중 낮은 것
        let expectedHeight = min(expectedSize.height,
                                 maxHeight)
        let clampedExpectedHeight = max(expectedHeight, minHeight)
        
        let roundedCurrent = round(textView.frame.height * 100) / 100
        let roundedExpected = round(clampedExpectedHeight * 100) / 100

        // 현재 텍스트뷰 높이와 조정할 높이가 같지 않다면?
        if roundedCurrent != roundedExpected {
            textView.isScrollEnabled = expectedSize.height > maxHeight
            textViewHeightConstraint?.update(offset: clampedExpectedHeight)
        }
    }
    
    private func setPlaceholder(isEmpty: Bool) {
        isPlaceHolder = isEmpty
        if isEmpty {
            textView.text = placeholderText
            textView.textColor = .gray05
        } else {
            textView.textColor = .gray02
        }
    }
    
    private func setBeginInputMode() {
        if isPlaceHolder {
            textView.text = ""
            isPlaceHolder = false
        }
        textView.textColor = .gray02
    }
}

extension Reactive where Base: DefaultTextView {
    var text: Observable<String?> {
        return base.textView.rx.text
            .filter { [weak base] _ in
                base?.isPlaceHolder == false
            }
    }
    
    var isResign: Binder<Bool> {
        return base.textView.rx.isResign
    }
    
    var isEditMode: Observable<Bool> {
        return base.editingObservable.asObservable()
    }
}
