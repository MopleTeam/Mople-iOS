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
    
    // MARK: - Variablesㅂ
    private var disposeBag = DisposeBag()
    
    // MARK: - Closure
    var menuTapped: (() -> Void)?
    var profileTapped: (() -> Void)?
    var likeTapped: (() -> Void)?
    var replyTapped: (() -> Void)?
    
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
            make.edges.equalToSuperview().inset(20)
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
                cell.likeTapped?()
            })
            .disposed(by: disposeBag)
        
        commentView.rx.replyTapped
            .subscribe(with: self, onNext: { cell, _ in
                
            })
            .disposed(by: disposeBag)
        
        bottomButton.rx.tap
            .subscribe(with: self, onNext: { cell, _ in
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    public func configure(with comment: Comment, isLastCell: Bool) {
        commentView.configure(.init(comment))
        setClearIndicator(isLoad: comment.isLoading)
        setBorderLine(hasBorder: !isLastCell)
    }
    
    public func mockConfigure() {
        setIndicator(isLoad: true)
    }

    // MARK: - Border Line
    public func setBorderLine(hasBorder: Bool) {
        borderView.isHidden = !hasBorder
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

