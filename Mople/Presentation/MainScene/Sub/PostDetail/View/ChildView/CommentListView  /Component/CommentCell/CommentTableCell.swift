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
    var likeTapped: (() -> Void)?
    var replyTapped: (() -> Void)?
    var onAppearPreview: (() -> Void)?
    
    // MARK: - Constraints
    private var leftPadding: Constraint?
    
    // MARK: - UI Components
    private let commentView = CommentView(frame: .zero)
    
    private let borderView = {
        let view = UIView()
        view.backgroundColor = .appStroke
        view.layer.zPosition = 1
        return view
    }()
    
    private let indicatorContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .bgPrimary
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
        
        // bind는 1회만 하므로 필요 없음
          // 하지만 안전하게 할거면 아래 방식 추천
          disposeBag = DisposeBag()
          setMenuAction()
          bind()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(commentView)
        self.contentView.addSubview(borderView)
        self.contentView.addSubview(indicatorContainer)
        self.indicatorContainer.addSubview(indicator)
        self.contentView.backgroundColor = .bgPrimary
        
        commentView.snp.makeConstraints { make in
            leftPadding = make.leading.equalToSuperview().inset(20).constraint
            make.verticalEdges.trailing.equalToSuperview().inset(20)
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
                cell.likeTapped?()
            })
            .disposed(by: disposeBag)
        
        commentView.rx.replyTapped
            .subscribe(with: self, onNext: { cell, _ in
                cell.replyTapped?()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    public func parentCommentConfigure(with comment: Comment, isLastCell: Bool) {
        commentView.configure(.init(comment))
        commentView.onAppearPreview = { [weak self] in
            self?.onAppearPreview?()
        }
        
        setClearIndicator(isLoad: comment.isLoading)
        setBorderLine(hasBorder: !isLastCell)
    }
    
    public func mockParentConfigure(isLastCell: Bool) {
        setIndicator(isLoad: true)
        setBorderLine(hasBorder: !isLastCell)
    }
    
    public func childCommentConfigure(with comment: Comment) {
        commentView.configure(.init(comment), showReply: false)
        setClearIndicator(isLoad: comment.isLoading)
        setBorderLine(hasBorder: false)
        leftPadding?.update(offset: comment.type == .parent ? 20 : 60)
    }
    
    public func mockChildConfigure() {
        setIndicator(isLoad: true)
        setBorderLine(hasBorder: false)
    }
    
    // MARK: - Border Line
    public func setBorderLine(hasBorder: Bool) {
        borderView.isHidden = !hasBorder
    }

    // MARK: - Set Loading
    private func setIndicator(isLoad: Bool) {
        indicatorContainer.backgroundColor = .bgPrimary
        setLoading(isLoad: isLoad)
    }
    
    private func setLoading(isLoad: Bool) {
        print(#function, #line, "Path : #  ")
        indicatorContainer.isHidden = !isLoad
        isLoad ? indicator.startAnimating() : indicator.stopAnimating()
    }
    
    public func setClearIndicator(isLoad: Bool) {
        indicatorContainer.backgroundColor = .clear
        setLoading(isLoad: isLoad)
    }
}


