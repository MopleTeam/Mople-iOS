//
//  LikeView.swift
//  Mople
//
//  Created by CatSlave on 7/23/25.
//

import UIKit
import Core
import RxSwift
import RxCocoa

final class ButtonCountView: UIView {
    
    private var disposeBag = DisposeBag()
    private var isHaptic: Bool = false
    
    // MARK: - UI Components
    fileprivate let button: UIButton = {
        let btn = UIButton()
        btn.setImage(.likeOff, for: .normal)
        return btn
    }()
    
    fileprivate let countLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = .text03
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [button, countLabel])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        button.snp.makeConstraints { make in
            make.size.equalTo(28)
        }
        
        countLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(26)
        }
    }
    
    // MARK: - Configure
    public func configure(image: UIImage, count: Int, isHaptic: Bool = false) {
        button.setImage(image, for: .normal)
        countLabel.text = count > 0 ? count.formatCompactNumber() : nil
        self.isHaptic = isHaptic
    }
    
    private func bind() {
        button.rx.tap
            .filter({ self.isHaptic })
            .subscribe(onNext: { _ in
                HapticManager.shared.playHaptics()
            })
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: ButtonCountView {
    var tap: ControlEvent<Void> {
        return base.button.rx.controlEvent(.touchUpInside)
    }
}

