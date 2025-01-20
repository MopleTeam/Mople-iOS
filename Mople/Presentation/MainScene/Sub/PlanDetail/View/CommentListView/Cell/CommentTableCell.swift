//
//  CommentTableCell.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import UIKit

final class CommentTableCell: UITableViewCell {
    private let profileView: ParticipantImageView = {
        let view = ParticipantImageView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.semiBold
        label.textColor = ColorStyle.Gray._02
        label.text = "이름"
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.regular
        label.textColor = ColorStyle.Gray._04
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.text = "시간댓글"
        return label
    }()
    
    private let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(.menu, for: .normal)
        return button
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = ColorStyle.Gray._03
        label.numberOfLines = 0
        label.text = "댓글 테스트"
        return label
    }()
    
    private lazy var commentHeaderView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameLabel, timeLabel, menuButton])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var commentView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [commentHeaderView, commentLabel])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [profileView, commentView])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.alignment = .top
        sv.distribution = .fill
        return sv
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.layer.makeLine(width: 1)
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        borderView.isHidden = false
    }
    
    private func setLayout() {
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(borderView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        profileView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        
        commentHeaderView.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(20)
        }
        
        borderView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
    }
}

extension CommentTableCell {
    public func hideLine(isLast: Bool) {
        borderView.isHidden = isLast
    }
}
