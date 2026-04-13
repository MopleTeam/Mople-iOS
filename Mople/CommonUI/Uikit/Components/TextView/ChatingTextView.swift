//
//  ChatingTextView.swift
//  Mople
//
//  Created by CatSlave on 7/17/25.
//

import UIKit
import Domain
import SnapKit
import RxSwift
import RxCocoa

final class ChatingTextFieldView: UIView {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Observable
    fileprivate let sendButton: BaseButton = {
        let btn = BaseButton()
        btn.setBgColor(normalColor: .clear)
        btn.isEnabled = false
        return btn
    }()
    
    private let editLabel: UILabel = {
        let label = UILabel()
        label.text = "댓글 수정중"
        label.font = FontStyle.Body2.medium
        label.textColor = UIColor.text03
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.bgSecondary
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private let sendImageView: UIImageView = {
        let view = UIImageView(image: .sendArrowCircleDisable)
        view.backgroundColor = .clear
        return view
    }()
    
    public let textView: DefaultTextView = {
        let view = DefaultTextView()
        view.setPlaceholderText(text: "@으로 멘션할 수 있어요!")
        return view
    }()
    
    private lazy var chatingStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [textView, sendButton])
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [editLabel, chatingStackView])
        sv.axis = .vertical
        sv.alignment = .leading
        sv.distribution = .fill
        sv.spacing = 8
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
        self.addSubview(mainStackView)
        self.sendButton.addSubview(sendImageView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(16).priority(.high)
            make.horizontalEdges.equalToSuperview().inset(20).priority(.high)
            make.bottom.equalToSuperview()
        }
        
        chatingStackView.snp.makeConstraints { make in
            make.width.equalTo(mainStackView.snp.width)
        }
        
        editLabel.snp.makeConstraints { make in
            make.height.equalTo(25)
            make.width.equalTo(70)
        }
        
        sendButton.snp.makeConstraints { make in
            make.width.equalTo(52)
        }
        
        sendImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.trailing.equalToSuperview()
            make.bottom.equalToSuperview().inset(6)
            make.height.equalTo(sendImageView.snp.width)
        }
    }
    
    private func bind() {
        self.textView.rx.isEditMode
            .asDriver(onErrorJustReturn: false)
            .map({ !$0 })
            .drive(self.sendButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        self.textView.rx.text
            .compactMap { $0 }
            .map { $0.count > 0 }
            .asDriver(onErrorJustReturn: false)
            .drive(with: self, onNext: { vc, isSendable in
                vc.sendButton.isEnabled = isSendable
                vc.sendImageView.image = isSendable ? .sendArrowCircle : .sendArrowCircleDisable
            })
            .disposed(by: disposeBag)
    }
    
    public func hideEditLabel(isHide: Bool) {
        editLabel.isHidden = isHide
    }
}

extension Reactive where Base: ChatingTextFieldView {
    var sendMessage: Observable<MessageInfo> {
        return base.sendButton.rx.controlEvent(.touchUpInside)
            .map { _ in base.textView.messageInfo }
            .compactMap { $0 }
    }
}
