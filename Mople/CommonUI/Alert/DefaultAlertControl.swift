//
//  DefaultAlertControl.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import UIKit

final class DefaultAlertControl: UIViewController {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorStyle.Gray._01
        label.font = FontStyle.Title2.semiBold
        label.textAlignment = .center
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = ColorStyle.Gray._02
        label.font = FontStyle.Body1.regular
        label.textAlignment = .center
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel])
        sv.axis = .vertical
        sv.spacing = 8
        sv.distribution = .fill
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        return sv
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fillEqually
        sv.alignment = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStackView, buttonStackView])
        sv.axis = .vertical
        sv.spacing = 24
        sv.distribution = .fill
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 24, left: 16, bottom: 16, right: 16)
        sv.layer.cornerRadius = 10
        sv.backgroundColor = ColorStyle.Default.white
        return sv
    }()
    
    init(title: String?,
         subTitle: String?,
         defaultAction: DefaultAction,
         addAction: [DefaultAction] = []) {
        super.init(nibName: nil, bundle: nil)
        setModalStyle()
        setTitle(title: title, subTitle: subTitle)
        addButtons(defaultAction: defaultAction,
                   addActions: addAction)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
    
    private func setModalStyle() {
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationStyle = .overFullScreen
    }
        
    private func setLayout() {
        self.view.backgroundColor = ColorStyle.Default.black.withAlphaComponent(0.6)
        self.view.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(320)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.height.equalTo(54)
        }
    }
}

// MARK: - 텍스트 셋팅
extension DefaultAlertControl {
    private func setTitle(title: String?,
                          subTitle: String?) {
        titleLabel.text = title
        setSubTitle(subTitle: subTitle)
    }
    
    private func setSubTitle(subTitle: String?) {
        guard let subTitle else { return }
        subTitleLabel.text = subTitle
        headerStackView.addArrangedSubview(subTitleLabel)
    }
}

// MARK: - 버튼 셋팅
extension DefaultAlertControl {
    private func addButtons(defaultAction: DefaultAction,
                            addActions: [DefaultAction]) {
        let defaultButton = actionButtonBulider(action: defaultAction,
                                                dismissAnimated: true)
        buttonStackView.addArrangedSubview(defaultButton)
        
        addActions.forEach {
            let buttons = actionButtonBulider(action: $0)
            buttonStackView.addArrangedSubview(buttons)
        }
    }
    
    private func actionButtonBulider(action: DefaultAction,
                                     dismissAnimated: Bool = false) -> BaseButton {
        let btn = BaseButton()
        btn.setTitle(text: action.text,
                     font: FontStyle.Title3.semiBold,
                     normalColor: action.tintColor)
        btn.setRadius(6)
        btn.setBgColor(normalColor: action.bgColor)
        btn.addAction(makeAction(action.completion,
                                 dismissAnimated: dismissAnimated),
                      for: .touchUpInside)
        return btn
    }
    
    private func makeAction(_ action: (() -> Void)?, dismissAnimated: Bool) -> UIAction {
        return .init { [weak self] _ in
            self?.dismiss(animated: dismissAnimated,
                          completion: action)
        }
    }
}


