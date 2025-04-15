//
//  CheckView.swift
//  Mople
//
//  Created by CatSlave on 4/15/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class CheckView: UIView {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Gesture
    fileprivate let checkBoxTouch = UITapGestureRecognizer()
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.medium
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = ColorStyle.Gray._04
        return label
    }()
    
    fileprivate let checkButton: UISwitch = {
        let switchBtn = UISwitch()
        switchBtn.onTintColor = ColorStyle.App.primary
        switchBtn.isOn = false
        switchBtn.isUserInteractionEnabled = false
        return switchBtn
    }()
    
    fileprivate let toggleButton = UIButton()
    
    private lazy var titleStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, subTitle])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleStackView, checkButton])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(mainStackView)
        self.mainStackView.addSubview(toggleButton)
        
        mainStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.verticalEdges.equalToSuperview().inset(6.5)
        }
        
        checkButton.snp.makeConstraints { make in
            make.width.equalTo(44)
            make.height.equalTo(26)
        }
        
        toggleButton.snp.makeConstraints { make in
            make.edges.equalTo(checkButton)
        }
    }
}

extension CheckView {
    public func setTitle(_ title: String) {
        titleLabel.text = title
    }
    
    public func setSubTitle(_ title: String) {
        subTitle.text = title
    }
    
    public func setSubscribe(isSubscribe: Bool) {
        guard checkButton.isOn != isSubscribe else { return }
        checkButton.isOn = isSubscribe
    }
}

extension Reactive where Base: CheckView {
    
    var changeValue: Observable<Bool> {
        return base.toggleButton.rx.controlEvent(.touchUpInside)
            .map { !base.checkButton.isOn }
    }
    
    var isEnabled: Binder<Bool> {
        return Binder(self.base) { checkView, isEnabled in
            base.toggleButton.isEnabled = isEnabled
            
            if !isEnabled {
                base.setSubscribe(isSubscribe: false)
            }
        }
    }
}
