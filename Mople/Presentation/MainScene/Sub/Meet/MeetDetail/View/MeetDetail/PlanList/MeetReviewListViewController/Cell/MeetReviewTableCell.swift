//
//  PastPlanTableCell.swift
//  Mople
//
//  Created by CatSlave on 1/7/25.
//

import UIKit
import SnapKit

final class MeetReviewTableCell: UITableViewCell {
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = ColorStyle.Gray._04
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()

    private let arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .listArrow
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._01
        return label
    }()

    private let countInfoLabel: IconLabel = {
        let label = IconLabel(icon: .member, iconSize: .init(width: 20, height: 20))
        label.setTitle(font: FontStyle.Body2.medium, color: ColorStyle.Gray._04)
        label.setSpacing(4)
        label.setTitleTopPadding(3)
        return label
    }()
    
    private let imageContainer = UIView()
    
    private let photoView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.layer.makeLine(width: 1)
        imageView.image = .defaultMeet
        return imageView
    }()
    
    private let photoCountLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.semiBold
        label.textColor = ColorStyle.App.primary
        label.backgroundColor = ColorStyle.Default.blueGray
        label.layer.makeLine(width: 1, color: ColorStyle.Default.white)
        label.textAlignment = .center
        label.clipsToBounds = true
        label.isHidden = true
        return label
    }()
    
    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [dateLabel, arrowImage])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    private lazy var bodyStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, countInfoLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        sv.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        sv.setContentHuggingPriority(.init(1), for: .horizontal)
        return sv
    }()
    
    private lazy var bottomStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [bodyStackView, imageContainer])
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStackView, bottomStackView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.Default.white
        sv.layer.cornerRadius = 12
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return sv
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
        photoCountLabel.isHidden = true
    }
    
    private func setLayout() {
        self.backgroundColor = .clear
        self.contentView.addSubview(mainStackView)
        self.imageContainer.addSubview(photoView)
        self.imageContainer.addSubview(photoCountLabel)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
        
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(24).priority(.high)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22).priority(.high)
        }
        
        countInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(20).priority(.high)
        }
        
        photoView.snp.makeConstraints { make in
            make.size.equalTo(48)
            make.edges.equalToSuperview().inset(4)
        }
        
        photoCountLabel.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.trailing.bottom.equalToSuperview()
        }
        
        photoCountLabel.layer.cornerRadius = 10
    }
    
    public func configure(viewModel: MeetReviewTableCellModel) {
        self.dateLabel.text = viewModel.dateString
        self.titleLabel.text = viewModel.title
        self.countInfoLabel.text = viewModel.participantCountString
        setCountInfo(viewModel.images.count)
        setImageInfo(imagePaths: viewModel.images)
    }
    
    private func setCountInfo(_ count: Int) {
        guard count > 0 else { return }
        photoCountLabel.isHidden = false
        photoCountLabel.text = "\(count)"
    }
    
    private func setImageInfo(imagePaths: [String]) {
        guard !imagePaths.isEmpty,
              let firstImagePath = imagePaths.first else { return }
        _ = photoView.kfSetimage(firstImagePath,
                                 defaultImageType: .history)
        
    }
}
