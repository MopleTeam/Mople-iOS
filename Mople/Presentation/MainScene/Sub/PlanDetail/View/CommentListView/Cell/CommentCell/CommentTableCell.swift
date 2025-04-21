//
//  CommentTableCell.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import SnapKit

final class CommentTableCell: UITableViewCell {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Closure
    var menuTapped: (() -> Void)?
    
    // MARK: - UI Components
    private let profileView: ProfileView = {
        let view = ProfileView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.semiBold
        label.textColor = ColorStyle.Gray._02
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.regular
        label.textColor = ColorStyle.Gray._04
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()
    
    fileprivate let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(.menu, for: .normal)
        return button
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = ColorStyle.Gray._03
        label.numberOfLines = 0
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
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileView.cancleImageLoad()
        borderView.isHidden = false
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(borderView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20).priority(.high)
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
    
    // MARK: - Action
    private func setAction() {
        self.menuButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { cell, _ in
                cell.menuTapped?()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    public func configure(_ viewModel: CommentTableCellModel) {
        self.profileView.setImage(viewModel.writerImagePath)
        self.nameLabel.text = viewModel.writerName
        self.commentLabel.text = viewModel.comment
        self.timeLabel.text = viewModel.commentDate
        self.borderView.isHidden = viewModel.isLastComment
    }
}
