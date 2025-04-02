//
//  MemberListTableCell.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import UIKit
import SnapKit

final class MemberListTableCell: UITableViewCell {
        
    private let memberInfoView: MemberInfoView = {
        let view = MemberInfoView()
        view.layer.cornerRadius = 20
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.medium
        label.textColor = ColorStyle.Gray._02
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [memberInfoView, nameLabel])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.distribution = .fill
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 8, left: 0, bottom: 8, right: 0)
        return sv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.top.equalToSuperview()
            make.bottom.equalTo(4)
        }
        
        memberInfoView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }

    public func configure(with viewModel: MemberListTableCellModel) {
        nameLabel.text = viewModel.nickName
        memberInfoView.setConfigure(imagePath: viewModel.imagePath,
                                    position: viewModel.position)
    }
}


