//
//  CommentView.swift
//  Mople
//
//  Created by CatSlave on 7/23/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class CommentView: UIView {
    
    // MARK: - Closure
    var urlPreview: ((URL) -> Void)?
    
    // MARK: - Variables
    public let spacing: CGFloat = 12
    
    var text: String {
        get { commentTextView.text }
        set { commentTextView.text = newValue }
    }
    
    // MARK: - Constraints
    private var imageSize: Constraint?
    
    // MARK: - UI Components
    fileprivate let profileView: UserImageView = {
        let view = UserImageView()
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        return view
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.semiBold
        label.textColor = .gray02
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.regular
        label.textColor = .gray04
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    fileprivate let menuButton: UIButton = {
        let button = UIButton()
        button.setImage(.menu, for: .normal)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
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
        view.clipsToBounds = true
        return view
    }()
    
    fileprivate let likeButton = ButtonCountView()
    
    fileprivate let replyButton = ButtonCountView()

    private lazy var commentHeaderView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [nameLabel, timeLabel, menuButton])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var commentStateView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [likeButton, replyButton])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var commentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [commentTextView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var bodyStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [commentHeaderView, commentStackView, commentStateView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .leading
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [profileView, bodyStackView])
        sv.axis = .horizontal
        sv.spacing = spacing
        sv.alignment = .top
        sv.distribution = .fill
        return sv
    }()
    
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
            make.edges.equalToSuperview().priority(.high)
        }
        
        commentHeaderView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        commentHeaderView.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        profileView.snp.makeConstraints { make in
            imageSize = make.size.equalTo(32).constraint
        }
    }
    
    // MARK: - Configure
    public func configure(_ viewModel: CommentViewModel, showReply: Bool = true) {
        setProfileView(with: viewModel)
        self.nameLabel.text = viewModel.writerName
        self.commentTextView.setTextFromServer(text: viewModel.text, mentions: viewModel.mentions)
        self.timeLabel.text = viewModel.commentDate
        self.likeButton.configure(image: viewModel.isLiked ? .likeOn : .likeOff,
                                  count: viewModel.likeCount,
                                  isHaptic: true)
        if showReply {
            setReplyButton(with: viewModel)
        } else {
            replyButton.isHidden = true
        }
        
        extractURLs()
    }
    
    private func setProfileView(with viewModel: CommentViewModel) {
        self.profileView.setImage(viewModel.writerThumbnailPath)
        self.imageSize?.update(offset: getImageSize(type: viewModel.type))
    }
    
    private func setReplyButton(with viewModel: CommentViewModel) {
        self.replyButton.configure(image: viewModel.replyCount > 0 ? .replyCommentOn : .replyComment,
                                  count: viewModel.replyCount)
    }
    
    // MARK: - Control
    public func cancleImageLoad() {
        profileView.cancleImageLoad()
    }
    
    public func getImageSize(type: CommentType) -> CGFloat {
        return type == .parent ? 32 : 28
    }
    
    public func resetContent() {
        self.nameLabel.text = nil
        self.commentTextView.text = nil
        self.timeLabel.text = nil
        self.profileView.resetImage()
    }
}

extension CommentView {
    private func extractURLs() {
        guard let text = commentTextView.text,
              let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return }
        
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let previewUrl = matches.last?.url {
            urlPreview?(previewUrl)
        }
    }
}

extension Reactive where Base: CommentView {
    
    var menuTapped: ControlEvent<Void> {
        return base.menuButton.rx.controlEvent(.touchUpInside)
    }
    
    var imageTapped: Observable<String?> {
        return base.profileView.rx.tap
    }
    
    var likeTapped: ControlEvent<Void> {
        return base.likeButton.rx.tap
    }
    
    var replyTapped: ControlEvent<Void> {
        return base.replyButton.rx.tap
    }
}
