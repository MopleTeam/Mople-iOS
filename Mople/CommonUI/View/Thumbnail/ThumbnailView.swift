//
//  ThumbnailView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

final class ThumbnailTitleView: UIView {
    
    enum ViewType {
        enum contentSize {
            case small
            case large
        }
        
        case simple
        case basic
        case detail(size: contentSize)
    }
    
    private var viewType: ViewType
    private var viewModel: ThumbnailViewModel?
    
    private let thumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private let groupTitleLabel = UILabel()
    
    private let memberCountLabel: IconLabel = {
        let label = IconLabel(icon: .member, iconSize: 20)
        label.setTitle(font: FontStyle.Body2.medium,
                       color: ColorStyle.Gray._04)
        label.setSpacing(4)
        label.setTitleTopPadding(3)
        return label
    }()
    
    private lazy var arrowImage: UIImageView = {
        let view = UIImageView()
        view.image = .listArrow
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var groupInfoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [groupTitleLabel])
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
    
    
    init(type: ViewType) {
        self.viewType = type
        defer { setupUI() }
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        handleUseType()
    }
    
    private func setTitleLabel(font: UIFont, color: UIColor) {
        groupTitleLabel.font = font
        groupTitleLabel.textColor = color
    }
    
    private func setThumbnail(size: CGFloat, radius: CGFloat) {
        thumbnailView.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        thumbnailView.layer.cornerRadius = radius
    }
    
    
    public func configure(with viewModel: ThumbnailViewModel?) {
        guard let viewModel = viewModel else { return }
        self.viewModel = viewModel
        loadImage(viewModel.thumbnailPath)
        groupTitleLabel.text = viewModel.name
        memberCountLabel.text = "\(self.viewModel?.memberCount ?? 0) 명"
    }

    private func loadImage(_ path: String?) {
        _ = thumbnailView.kfSetimage(path)
    }
}

extension ThumbnailTitleView {
    private func handleUseType() {
        handleSize()
        handleUI()
    }
    
    private func handleSize() {
        switch viewType {
        case .simple, .basic:
            setSpacing(8)
            setThumbnail(size: 28, radius: 6)
        case .detail:
            setSpacing(12)
            setThumbnail(size: 56, radius: 12)
        }
    }
    
    private func handleUI() {
        switch viewType {
        case .simple:
            setTitleLabel(font: FontStyle.Body1.medium,
                          color: ColorStyle.Gray._02)
        case .basic:
            addArrowImageView()
            setTitleLabel(font: FontStyle.Body2.semiBold,
                          color: ColorStyle.Gray._04)
        case let .detail(size):
            self.handleDetailTypeUI(size: size)
        }
    }
    
    private func handleDetailTypeUI(size: ViewType.contentSize) {
        switch size {
        case .small:
            addArrowImageView()
            addMemberCountLabel()
            setTitleLabel(font: FontStyle.Title3.semiBold,
                          color: ColorStyle.Gray._01)
        case .large:
            addMemberCountLabel()
            setTitleLabel(font: FontStyle.Title2.semiBold,
                          color: ColorStyle.Gray._01)
        }
    }
}

extension ThumbnailTitleView {
    private func addMemberCountLabel() {
        groupInfoStackView.addArrangedSubview(memberCountLabel)
    }
    
    private func addArrowImageView() {
        mainStackView.addArrangedSubview(arrowImage)
    }
    
    private func setSpacing(_ space: CGFloat) {
        mainStackView.spacing = space
    }
}
