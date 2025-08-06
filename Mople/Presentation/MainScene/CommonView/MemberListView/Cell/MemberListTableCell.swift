//
//  MemberListTableCell.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import UIKit
import RxSwift
import SnapKit

final class MemberListTableCell: UITableViewCell {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Closure
    var profileTapped: (() -> Void)?
        
    // MARK: - UI Components
    private let memberView = MemberView()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setImageTapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubview(memberView)
        
        memberView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(12)
            make.bottom.equalToSuperview().inset(8)
        }
    }

    public func configure(with memberInfo: MemberInfo) {
        memberView.configure(memberInfo: memberInfo)
    }
    
    // MARK: - Gesture
    private func setImageTapGesture() {
        self.memberView.memberInfoView.profileView.rx.tap
            .subscribe(with: self, onNext: { cell, _ in
                cell.profileTapped?()
            })
            .disposed(by: disposeBag)
    }
}

final class MemberView: UIView {
    
    public let memberInfoView: MemberInfoView = {
        let view = MemberInfoView()
        view.layer.cornerRadius = 20
        return view
    }()
    
    public let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.medium
        label.textColor = .gray02
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [memberInfoView, nameLabel])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .clear
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        memberInfoView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }

    public func configure(memberInfo: MemberInfo) {
        nameLabel.text = memberInfo.nickname
        memberInfoView.setConfigure(memberInfo: memberInfo)
    }
    
    public func setFont(font: UIFont) {
        nameLabel.font = font
    }
}
