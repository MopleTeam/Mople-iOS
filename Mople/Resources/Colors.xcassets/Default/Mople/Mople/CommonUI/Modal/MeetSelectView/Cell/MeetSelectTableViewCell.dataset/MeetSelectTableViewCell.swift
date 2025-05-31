//
//  GroupSelectTableViewCell.swift
//  Mople
//
//  Created by CatSlave on 12/14/24.
//

import UIKit
import SnapKit

final class MeetSelectTableCell: UITableViewCell {
        
    // MARK: - UI Components
    private let thumbnailView: ThumbnailView = {
        let view = ThumbnailView(thumbnailSize: 28,
                                      thumbnailRadius: 6)
        view.setTitleLabel(font: FontStyle.Body1.medium,
                           color: .gray02)
        view.setSpacing(8)
        return view
    }()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Highlight
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.contentView.backgroundColor = highlighted ? .bgInput : .defaultWhite
    }

    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .defaultWhite
        self.contentView.addSubview(thumbnailView)
        
        thumbnailView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview()
        }
    }

    // MARK: - Configure
    public func configure(with viewModel: ThumbnailViewModel?) {
        guard let viewModel = viewModel else { return }
        thumbnailView.configure(with: viewModel)
    }
}
