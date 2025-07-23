//
//  CommentTableCell.swift
//  Mople
//
//  Created by CatSlave on 1/16/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CommentTableCell: UITableViewCell {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Closure
    var menuTapped: (() -> Void)?
    var profileTapped: (() -> Void)?
    
    // MARK: - UI Components
    private let profileView: UserImageView = {
        let view = UserImageView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.semiBold
        label.textColor = .gray02
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.regular
        label.textColor = .gray04
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()
    
    fileprivate let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(.menu, for: .normal)
        return button
    }()
    
    private let commentTextView: UITextView = {
        let view = UITextView()
        view.font = FontStyle.Body1.medium
        view.textColor = .gray03
        view.dataDetectorTypes = .link
        view.isUserInteractionEnabled = true
        view.isSelectable = true
        view.isScrollEnabled = false
        view.isEditable = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        return view
    }()
    
    private let likeView = LikeView()
    
    private let replyImageView: UIImageView = {
        let view = UIImageView(image: .replyComment)
        return view
    }()
    
    private let moreReplyCommentLabel: IconLabel = {
        let label = IconLabel(icon: .downArrow2,
                              iconSize: .init(width: 20, height: 20))
        label.setTitle(font: FontStyle.Body2.semiBold,
                       color: .gray04)
        label.rightIconAligment()
        label.centerIconAligment()
        label.text = "답글 1개 더 보기"
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
    
    private lazy var commentStateView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [likeView, replyImageView])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var commentView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [commentHeaderView, commentTextView, commentStateView, moreReplyCommentLabel])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .leading
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
        setMenuAction()
        setImageTapGesture()
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
        
        commentTextView.snp.makeConstraints { make in
            make.height.greaterThanOrEqualTo(20)
        }
        
        borderView.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    // MARK: - Action
    private func setMenuAction() {
        self.menuButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { cell, _ in
                cell.menuTapped?()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Gesture
    private func setImageTapGesture() {
        self.profileView.rx.tap
            .subscribe(with: self, onNext: { cell, _ in
                cell.profileTapped?()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    public func configure(_ viewModel: CommentTableCellModel) {
        self.profileView.setImage(viewModel.writerImagePath)
        self.nameLabel.text = viewModel.writerName
        self.commentTextView.text = viewModel.comment
        self.timeLabel.text = viewModel.commentDate
        self.borderView.isHidden = viewModel.isLastComment
    }
}


final class LikeView: UIView {
    
    // MARK: - UI Components
    fileprivate let likeImageView: UIImageView = {
        let view = UIImageView(image: .likeOff)
        return view
    }()
    
    fileprivate let countLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = .gray04
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [likeImageView, countLabel])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    // MARK: - Life Cycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
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
        
        likeImageView.snp.makeConstraints { make in
            make.size.equalTo(28)
        }
        
        countLabel.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(26)
        }
    }
    
    public func configureLike(isLike: Bool, likeCount: Int) {
        likeImageView.image = isLike ? .likeOn : .likeOff
        countLabel.text = likeCount.formatCompactNumber()
    }
}


