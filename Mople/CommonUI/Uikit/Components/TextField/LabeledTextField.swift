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
        label.textColor = .text01
        return label
    }()
    
    private(set) lazy var textField = DefaultTextField()

    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, textField])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.layer.cornerRadius = 8
        sv.clipsToBounds = true
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
extension LabeledTextField {
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
extension LabeledTextField {
    
    public func setInputTextField(view: UIView, mode: DefaultTextField.ViewMode) {
        self.textField.setInputTextField(view: view, mode: mode)
    }
}

final class LabeledTextView: UIView {
    
    enum ViewMode {
        case left
        case right
    }
    
    public var text: String? {
        get {
            return textView.text
        } set {
            textView.text = newValue
        }
    }
    
    private var disposeBag = DisposeBag()
        
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
    
    private lazy var topSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel])
        sv.axis = .horizontal
        sv.spacing = 4
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    public let textView: DefaultTextView = {
        let view = DefaultTextView()
        view.updateInset(.zero)
        view.setMaxCount(100)
        return view
    }()
    
    private let countView : UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.regular
        label.textColor = .text04
        label.text = "0/100"
        label.textAlignment = .right
        return label
    }()
    
    private lazy var textViewSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [textView, countView])
        sv.backgroundColor = .bgInput
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 18, left: 16, bottom: 18, right: 16)
        sv.layer.cornerRadius = 8
        sv.clipsToBounds = true
        return sv
    }()

    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [topSV, textViewSV])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(title: String,
         placeholder: String,
         maxTextCount: Int) {
        super.init(frame: .zero)
        initialsetup(title, placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initialsetup(_ title: String,_ placeholder: String) {
        setTitle(title)
        setPlaceHolder(text: placeholder)
        setupUI()
        bind()
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22)
        }
        
        textView.snp.makeConstraints { make in
            make.height.equalTo(80)
        }
    }
    
    private func bind() {
        textView.rx.text
            .compactMap { $0 }
            .map({ $0.count })
            .bind(with: self, onNext: { view, count in
                view.countView.text = "\(count)/100"
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - 텍스트 설정
extension LabeledTextView {
    private func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    private func setPlaceHolder(text: String) {
        self.textView.setPlaceholderText(text: text)
    }
    
    private func setMaxCount(_ maxCount: Int) {
        self.textView.setMaxCount(maxCount)
    }
    
    public func setOptionLabel() {
        topSV.addArrangedSubview(optionLabel)
    }
}
