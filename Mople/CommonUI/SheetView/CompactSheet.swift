//
//  SheetTableView.swift
//  Mople
//
//  Created by CatSlave on 12/17/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CompactSheet: UIView {
    // MARK: - Observer
    public var closeButtonTap: ControlEvent<Void> {
        return closeButton.rx.controlEvent(.touchUpInside)
    }
    
    // MARK: - UI Components
    private let contentView: UIView
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title2.semiBold
        label.textColor = ColorStyle.Gray._02
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.close, for: .normal)
        return btn
    }()
    
    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, closeButton])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        sv.layoutMargins = .init(top: 0, left: 20, bottom: 0, right: 20)
        sv.isLayoutMarginsRelativeArrangement = true
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStackView, contentView])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.layer.cornerRadius = 13
        sv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return sv
    }()
    
    init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.backgroundColor = ColorStyle.Default.white
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
    }
    
    public func setTitle(_ title: String?) {
        titleLabel.text = title
    }
}

