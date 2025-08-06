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
    private var loadState: BottomButtonState = .none
    private var comment: Comment?
    
    // MARK: - Closure
    var menuTapped: (() -> Void)?
    var profileTapped: (() -> Void)?
    var likeTapped: ((Int) -> Void)?
    var replyTapped: ((Int) -> Void)?
    var moreReply: ((Int) -> Void)?
    var hideReply: ((Int) -> Void)?
    
    // MARK: - Constraints
    private var topMargin: Constraint?
    private var leadingMargin: Constraint?
    private var bottomMargin: Constraint?
    
    // MARK: - UI Components
    private let commentView = CommentView(frame: .zero)
    
    private lazy var bottomButton: LoadingButtonView = {
        let view = LoadingButtonView()
        view.isUserInteractionEnabled = true
        view.button.setTitle(font: FontStyle.Body2.semiBold,
                             normalColor: .gray04)
        view.button.setImage(image: .downArrow2)
        view.isHidden = true
        return view
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [commentView, bottomButton])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .leading
        sv.distribution = .fill
        return sv
    }()
    
    private let borderView = {
        let view = UIView()
        view.backgroundColor = .appStroke
        view.layer.zPosition = 1
        return view
    }()
    
    private let indicatorContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultWhite
        return view
    }()
    
    private let indicator = UIActivityIndicatorView(style: .large)
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
        setMenuAction()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print(#function, #line, "Path : # ")
        commentView.resetContent()
        commentView.cancleImageLoad()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(borderView)
        self.contentView.addSubview(indicatorContainer)
        self.indicatorContainer.addSubview(indicator)
        self.contentView.backgroundColor = .defaultWhite
        
        mainStackView.snp.makeConstraints { make in
            topMargin = make.top.equalToSuperview().inset(20).constraint
            leadingMargin = make.leading.equalToSuperview().inset(20).constraint
            bottomMargin = make.bottom.equalToSuperview().constraint
            make.trailing.equalToSuperview().inset(20)
        }
        
        commentView.snp.makeConstraints { make in
            make.width.equalTo(mainStackView.snp.width)
        }
        
        borderView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        indicatorContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(20)
        }
    }
    
    // MARK: - Action
    private func setMenuAction() {
        commentView.rx.menuTapped
            .subscribe(with: self, onNext: { cell, _ in
                cell.menuTapped?()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Gesture
    private func bind() {
        commentView.rx.imageTapped
            .subscribe(with: self, onNext: { cell, _ in
                cell.profileTapped?()
            })
            .disposed(by: disposeBag)
        
        commentView.rx.likeTapped
            .subscribe(with: self, onNext: { cell, _ in
                guard let id = cell.comment?.id else { return }
                cell.likeTapped?(id)
            })
            .disposed(by: disposeBag)
        
        commentView.rx.replyTapped
            .subscribe(with: self, onNext: { cell, _ in
                cell.handleReplyTapped()
            })
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .subscribe(with: self, onNext: { cell, _ in
                cell.handleToggleTapped()
            })
            .disposed(by: disposeBag)
    }
    
    private func handleToggleTapped() {
        guard let id = getParentId() else { return }
        switch loadState {
        case .loadMore:
            if comment?.hasCachingReply == false {
                bottomButton.startLoading()
            }
            moreReply?(id)
        case .hidePgae:
            hideReply?(id)
        default:
            break
        }
    }
    
    private func handleReplyTapped() {
        guard let replyId = getParentId() else { return }
        replyTapped?(replyId)
    }
    
    private func getParentId() -> Int? {
        return comment?.type == .parent ? comment?.id : comment?.parentId
    }
    
    // MARK: - Configure
    public func configure(with model: CommentConfigurationModel) {
        self.comment = model.comment
        commentView.configure(.init(model.comment))
        setMargin(with: model.comment)
        configureBottomButton(with: model.bottomButtonState)
        setIndicator(isLoad: false)
        setBorderLine(hasBorder: model.hasBorder)
    }
    
    public func mockConfigure() {
        setIndicator(isLoad: true)
    }
    
    // MARK: - Set Margin
    private func setMargin(with comment: Comment) {
        setMainMargin(with: comment)
        setButtonMargin(with: comment)
    }
    
    private func setMainMargin(with comment: Comment) {
        let isParent = comment.type == .parent
        self.topMargin?.update(offset: isParent ? 20 : 24)
        self.leadingMargin?.update(offset: isParent ? 20 : 60)
    }
    
    private func setButtonMargin(with comment: Comment) {
        let commentSpacing = commentView.spacing
        let profileSize = commentView.getImageSize(type: comment.type)
        bottomButton.button.setLayoutMargins(inset: .init(top: 0,
                                          leading: profileSize + commentSpacing,
                                          bottom: 0, trailing: 0))
    }
    
    // MARK: - Set Bottom Button
    public func configureBottomButton(with state: BottomButtonState) {
        guard comment?.isMockup == false else { return }
        self.loadState = state
        bottomButton.stopLoading()
        switch state {
        case .loadMore(let count):
            setBottomButton(title: "답글 \(count)개 더 보기",
                            image: .downArrow2)
        case .hidePgae:
            setBottomButton(title: "답글 숨기기",
                            image: .upArrow)
        case .none:
            self.bottomButton.isHidden = true
        }
    }
    
    private func setBottomButton(title: String, image: UIImage) {
        self.bottomButton.button.title = title
        self.bottomButton.button.setImage(image: image)
        self.bottomButton.isHidden = false
    }
    
    // MARK: - Border Line
    public func setBorderLine(hasBorder: Bool) {
        borderView.isHidden = !hasBorder
        bottomMargin?.update(inset: hasBorder ? 20 : 0)
    }

    // MARK: - Set Loading
    private func setIndicator(isLoad: Bool) {
        indicatorContainer.backgroundColor = .defaultWhite
        setLoading(isLoad: isLoad)
    }
    
    private func setLoading(isLoad: Bool) {
        indicatorContainer.isHidden = !isLoad
        isLoad ? indicator.startAnimating() : indicator.stopAnimating()
    }
    
    public func setClearIndicator(isLoad: Bool) {
        indicatorContainer.backgroundColor = .clear
        setLoading(isLoad: isLoad)
    }
}


// MARK: - Models
public struct CommentConfigurationModel {
    let comment: Comment
    var bottomButtonState: BottomButtonState
    var hasBorder: Bool
    
    // Factory methods for different scenarios
    static func comment(_ comment: Comment,
                        isLastCell: Bool) -> Self {
        let remainReplyCount = comment.remainReplyCount
        let loadReplyCount = comment.loadReplyCount
        let hasRemainReply = remainReplyCount > 0
        let hasLoadReply = loadReplyCount > 0
        let buttonState: BottomButtonState = hasRemainReply && !hasLoadReply
        ? .loadMore(remainReplyCount)
        : .none
        
        let hasBorder = !hasLoadReply && !isLastCell
        
        return Self(comment: comment,
                    bottomButtonState: buttonState,
                    hasBorder: hasBorder)
    }
    
    static func reply(parent: Comment,
                      reply: Comment,
                      isLastReply: Bool,
                      isLastCell: Bool) -> Self {
        let buttonState: BottomButtonState
        
        if isLastReply {
            let canLoad = parent.remainReplyCount > 0
            buttonState = canLoad ? .loadMore(parent.remainReplyCount) : .hidePgae
        } else {
            buttonState = .none
        }
        return Self(comment: reply,
                    bottomButtonState: buttonState,
                    hasBorder: isLastReply && !isLastCell)
    }
}

public enum BottomButtonState {
    case loadMore(Int)
    case hidePgae
    case none
}
