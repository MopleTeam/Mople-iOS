//
//  NotifyTableCell.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import UIKit
import SnapKit
import Kingfisher

final class NotifyTableCell: UITableViewCell {
    
    // MARK: - Variables
    private var task: DownloadTask?
    private var defaultColor: UIColor?
    
    // MARK: - UI Components
    private let thumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.makeLine(width: 1)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = .gray02
        label.numberOfLines = 2
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = .gray04
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, titleStackView])
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task = nil
    }
    
    // MARK: - Highlight
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        let color = highlighted ? .bgPrimary : defaultColor
        contentView.backgroundColor = color
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        thumbnailView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }
    
    public func configure(viewModel: NotifyViewModel) {
        task = thumbnailView.kfSetimage(viewModel.thumbnailPath,
                                        defaultImageType: .meet)
        titleLabel.text = viewModel.title
        subTitleLabel.text = viewModel.subTitle
    }
    
    public func setReadStatus(isNew: Bool) {
        defaultColor = isNew ? .bgInput : .clear
        contentView.backgroundColor = defaultColor
    }
}

