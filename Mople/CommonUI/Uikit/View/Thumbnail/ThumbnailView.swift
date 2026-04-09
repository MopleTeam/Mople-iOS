//
//  ThumbnailView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import RxSwift
import SnapKit

class ThumbnailView: UIView {
    
    // MARK: - UI Components
    private let thumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.setDynamicBorder(width: 1)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private let groupTitleLabel = {
        let label = UILabel()
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var owenrImage = {
        let imageView = UIImageView(image: .owner)
        imageView.isHidden = true
        imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        imageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        return imageView
    }()
    
    public lazy var memberCountLabel: IconLabel = {
        let label = IconLabel(icon: .member,
                              iconSize: .init(width: 20, height: 20))
        label.setTitle(font: FontStyle.Body2.medium,
                       color: .text03)
        label.setSpacing(4)
        return label
    }()
    
    private lazy var arrowImage: UIImageView = {
        let view = UIImageView()
        view.image = .listArrow
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var titleSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [groupTitleLabel])
        sv.axis = .horizontal
        sv.spacing = 4
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    public lazy var groupInfoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleSV])
        sv.axis = .vertical
        sv.spacing = 4
        sv.distribution = .fill
        sv.alignment = .leading
        sv.setContentHuggingPriority(.init(1), for: .horizontal)
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, groupInfoStackView])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    // MARK: - Gesture
    fileprivate let imageTapGesture: UITapGestureRecognizer = .init()
    
    // MARK: - LifeCycle
    init(thumbnailSize: CGFloat,
         thumbnailRadius: CGFloat) {
        super.init(frame: .zero)
        setupUI()
        setThumbnail(size: thumbnailSize,
                     radius: thumbnailRadius)
        setupImageGesture()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public func configure(with viewModel: ThumbnailViewModel?) {
        guard let viewModel = viewModel else { return }
        loadImage(viewModel.thumbnailPath)
        groupTitleLabel.text = viewModel.name
        setMemberCount(viewModel.memberCountString)
        setOwnerMark(isOwner: viewModel.isOwenr)
        print(#function, #line, "Path : # \(viewModel.name), \(viewModel.isOwenr) ")
    }
    
    private func setOwnerMark(isOwner: Bool) {
        
        owenrImage.isHidden = !isOwner
    }
    
    public func setMemberCount(_ countText: String?) {
        guard groupInfoStackView.subviews.contains(where: {
            $0 is IconLabel
        }) else { return }
        
        memberCountLabel.text = countText
    }

    private func loadImage(_ path: String?) {
        thumbnailView.kfSetimage(path, defaultImageType: .meet)
    }
    
    // MARK: - Gesture Setup
    private func setupImageGesture() {
        self.thumbnailView.addGestureRecognizer(imageTapGesture)
    }
}

extension ThumbnailView {
    public func setTitleLabel(font: UIFont, color: UIColor) {
        groupTitleLabel.font = font
        groupTitleLabel.textColor = color
    }
    
    public func setThumbnail(size: CGFloat, radius: CGFloat) {
        thumbnailView.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        thumbnailView.layer.cornerRadius = radius
    }
    
    public func addMemberCountLabel() {
        groupInfoStackView.addArrangedSubview(memberCountLabel)
    }
    
    public func addArrowImageView() {
        mainStackView.addArrangedSubview(arrowImage)
    }
    
    public func setSpacing(_ space: CGFloat) {
        mainStackView.spacing = space
    }
    
    public func addOwnerMark() {
        titleSV.addArrangedSubview(owenrImage)
        owenrImage.snp.makeConstraints { make in
            make.size.equalTo(16)
        }
    }
}

extension Reactive where Base: ThumbnailView {
    var imageTap: Observable<Void> {
        return base.imageTapGesture.rx.event
            .map { _ in }
    }
}
