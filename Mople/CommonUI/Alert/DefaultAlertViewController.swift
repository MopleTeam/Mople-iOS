//
//  DefaultAlertControl.swift
//  Mople
//
//  Created by CatSlave on 1/9/25.
//

import UIKit

final class DefaultAlertViewController: UIViewController {
    
    private lazy var warningView = UIView()
    
    private lazy var warningImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = .warning
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray01
        label.font = FontStyle.Title2.semiBold
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray02
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
        sv.backgroundColor = .defaultWhite
        return sv
    }()
    
    init(title: String?,
         subTitle: String?,
         defaultAction: DefaultAlertAction,
         addAction: [DefaultAlertAction] = []) {
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
        self.view.backgroundColor = .defaultBlack.withAlphaComponent(0.6)
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
extension DefaultAlertViewController {
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
extension DefaultAlertViewController {
    private func addButtons(defaultAction: DefaultAlertAction,
                            addActions: [DefaultAlertAction]) {
        let defaultButton = actionButtonBulider(action: defaultAction,
                                                dismissAnimated: true)
        buttonStackView.addArrangedSubview(defaultButton)
        
        addActions.forEach {
            let buttons = actionButtonBulider(action: $0)
            buttonStackView.addArrangedSubview(buttons)
        }
    }
    
    private func actionButtonBulider(action: DefaultAlertAction,
                                     dismissAnimated: Bool = true) -> BaseButton {
        let btn = BaseButton()
        btn.setTitle(text: action.text,
                     font: FontStyle.Title3.semiBold,
                     normalColor: action.tintColor)
        btn.setRadius(6)
        btn.setBgColor(normalColor: action.bgColor)
        btn.addAction(makeAction(action.completion,
                                 dismissAnimated: dismissAnimated),
                      for: .touchUpInside)
        btn.titleLabel?.textAlignment = .center
        return btn
    }
    
    private func makeAction(_ action: (() -> Void)?,
                            dismissAnimated: Bool) -> UIAction {
        return .init { [weak self] _ in
            self?.dismiss(animated: dismissAnimated,
                          completion: action)
        }
    }
}

extension DefaultAlertViewController {
    public func setWarningImage() {
        mainStackView.insertArrangedSubview(warningView, at: 0)
        warningView.addSubview(warningImageView)
        warningImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.verticalEdges.equalToSuperview()
            make.size.equalTo(40)
        }
    }
}


