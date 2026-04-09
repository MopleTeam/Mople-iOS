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
    
    // MARK: - Cache
    private static let metadataCache = NSCache<NSURL, LPLinkMetadata>()
    
    // MARK: - Closure
    var onAppearPreview: (() -> Void)?
    
    // MARK: - Variables
    private var metadataProvider: LPMetadataProvider?
    private var url: URL?
    
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
        label.textColor = .text01
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.regular
        label.textColor = .text03
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
        view.textColor = .text02
        view.dataDetectorTypes = .link
        view.isUserInteractionEnabled = true
        view.isSelectable = true
        view.isScrollEnabled = false
        view.isEditable = false
        view.textContainer.lineFragmentPadding = 0
        view.textContainerInset = .zero
        view.clipsToBounds = true
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var linkPreviewView: CustomPreviewView = {
        let view = CustomPreviewView()
        view.isHidden = true
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
        let sv = UIStackView(arrangedSubviews: [likeButton, replyButton, UIView()])
        sv.axis = .horizontal
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var commentStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [commentTextView, linkPreviewView])
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
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [profileView, bodyStackView])
        sv.axis = .horizontal
        sv.spacing = 12
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
            make.edges.equalToSuperview()
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
        
        linkPreviewView.snp.makeConstraints { make in
            make.height.equalTo(191).priority(.high)
        }
    }
    
    // MARK: - Configure
    public func configure(_ viewModel: CommentViewModel, showReply: Bool = true) {
        resetCommentView()
        setProfileView(with: viewModel)
        self.nameLabel.text = viewModel.writerName
        self.setCommentTextView(with: viewModel)
        self.timeLabel.text = viewModel.commentDate
        self.likeButton.configure(image: viewModel.isLiked ? .likeOn : .likeOff,
                                  count: viewModel.likeCount,
                                  isHaptic: true)
        if showReply {
            setReplyButton(with: viewModel)
        } else {
            replyButton.isHidden = true
        }
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
        cancleMetadataFetch()
    }
    
    private func cancleMetadataFetch() {
        metadataProvider?.cancel()
        metadataProvider = nil
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
    
    private func resetCommentView() {
        commentTextView.isHidden = false
        linkPreviewView.isHidden = true
    }
}

extension CommentView {
    private func setCommentTextView(with viewModel: CommentViewModel) {
        if let lastMatch = findLastMatch(with: viewModel.text),
           let range = Range(lastMatch.range, in: viewModel.text),
           let previewUrl = lastMatch.url {
     
            print(#function, #line, "Path : #111 \(previewUrl)")
            makeUrlPreview(with: previewUrl,
                           urlRange: range,
                           viewModel: viewModel)
        } else {
            commentTextView.setTextFromServer(text: viewModel.text, mentions: viewModel.mentions)
        }
    }
    
    private func findLastMatch(with text: String) -> NSTextCheckingResult? {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return nil
        }
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        return matches.last
    }
    
    private func makeUrlPreview(with url: URL,
                                urlRange: Range<String.Index>,
                                viewModel: CommentViewModel) {

        // Cache 먼저 체크
        if let cached = CommentView.metadataCache.object(forKey: url as NSURL) {
            print("🔹 cached metadata 사용")
            setUrlText(urlRange: urlRange, viewModel: viewModel)
            linkPreviewView.configure(with: cached)
            addUrlPreview()
            onAppearPreview?()
            return
        }

        // 요청 전 기존 작업 취소
        cancleMetadataFetch()

        self.url = url
        addUrlPreview()
        linkPreviewView.reset()

        metadataProvider = LPMetadataProvider()
        metadataProvider?.startFetchingMetadata(for: url) { [weak self] metadata, error in
            guard let self = self else { return }

            DispatchQueue.main.async {
                // ★ 셀 재사용으로 URL이 바뀐 경우 처리 중단
                guard self.url == url else { return }

                if let metadata = metadata, error == nil {
                    if metadata.title != nil {
                            CommentView.metadataCache.setObject(metadata, forKey: url as NSURL)
                        }

                    self.setUrlText(urlRange: urlRange, viewModel: viewModel)
                    self.linkPreviewView.configure(with: metadata)
                    self.onAppearPreview?()

                } else {
                    self.commentTextView.setTextFromServer(text: viewModel.text, mentions: viewModel.mentions)
                    self.removeUrlPreview()
                    self.onAppearPreview?()
                }
            }
        }
    }

    private func setUrlText(urlRange: Range<String.Index>, viewModel: CommentViewModel) {
        var newText = viewModel.text
        newText.removeSubrange(urlRange)
        let trimmed = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            commentTextView.isHidden = true
        } else {
            commentTextView.setTextFromServer(text: trimmed, mentions: viewModel.mentions)
        }
    }
    
    private func addUrlPreview() {
        linkPreviewView.isHidden = false
    }
    
    private func removeUrlPreview() {
        linkPreviewView.isHidden = true
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

import LinkPresentation

final class CustomPreviewView: UIView {
    
    private var linkURL: URL?

    
    private let thumbnailView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appBlack
        label.font = FontStyle.Body2.bold
        label.numberOfLines = 1
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appBlack
        label.font = FontStyle.Body2.regular
        label.numberOfLines = 2
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)
        return label
    }()
    
    private lazy var labelSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = .appTertiary
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 8, left: 8, bottom: 8, right: 8)
        return sv
    }()
    
    private lazy var mainSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, labelSV])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        sv.layer.cornerRadius = 12
        sv.clipsToBounds = true
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize { .zero }
    
    private func setupUI() {
        self.addSubview(mainSV)
        
        mainSV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    

    func configure(with metadata: LPLinkMetadata) {
        let title = metadata.title ?? metadata.originalURL?.absoluteString ?? "제목 없음"   // ← fallback 적용
            let description = (metadata.value(forKey: "summary") as? String) ?? ""

            titleLabel.text = title
            descriptionLabel.text = description

            // metadata가 갱신되는 경우 title이 나중에 들어올 수 있음 → observe 필요
            if metadata.title == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                    if let newTitle = metadata.title, !newTitle.isEmpty {
                        self?.titleLabel.text = newTitle      // ← 나중에 title 들어오면 update
                    }
                }
            }
        
        self.setNeedsLayout()
        self.layoutIfNeeded()

        // URL 저장
        linkURL = metadata.originalURL ?? metadata.url

        // 이미지 로드
        if let provider = metadata.imageProvider {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                DispatchQueue.main.async {
                    self?.thumbnailView.image = image as? UIImage
                }
            }
        }

        // 제스처 추가 (중복 방지)
        if gestureRecognizers?.isEmpty ?? true {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            addGestureRecognizer(tap)
            isUserInteractionEnabled = true
        }
    }
    
    func reset() {
        thumbnailView.image = nil
        titleLabel.text = nil
        descriptionLabel.text = nil   // ← 중요
    }

    @objc private func handleTap() {
        guard let url = linkURL else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
