//
//  CountView.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import UIKit
import RxSwift

final class CountView: UIView {
    
    var titleText: String? {
        get { titleLabel.text }
        set { titleLabel.text = newValue}
    }
    
    var countText: String? {
        get { countLabel.text }
        set { countLabel.text = newValue}
    }

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = .gray01
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = .gray04
        label.textAlignment = .right
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .bottom
        return stackView
    }()
    
    // MARK: - LifeCycle
    init(title: String? = nil) {
        super.init(frame: .zero)
        self.titleText = title
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(0)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(0)
        }
    }
}

extension CountView {
    public func setFont(font: UIFont,
                        textColor: UIColor) {
        self.setTitleFont(font: font, textColor: textColor)
        self.setCountFont(font: font, textColor: textColor)
    }
    
    public func setTitleFont(font: UIFont,
                         textColor: UIColor) {
        titleLabel.font = font
        titleLabel.textColor = textColor
    }
    
    public func setCountFont(font: UIFont,
                         textColor: UIColor) {
        countLabel.font = font
        countLabel.textColor = textColor
    }
    
    public func setBottomInset(_ inset: CGFloat) {
        mainStackView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().inset(inset)
        }
    }
}
