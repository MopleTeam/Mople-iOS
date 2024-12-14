//
//  GroupSelectTableViewCell.swift
//  Mople
//
//  Created by CatSlave on 12/14/24.
//

import UIKit
import SnapKit

final class GroupSelectTableCell: UITableViewCell {
        
    private let thumbnailView = ThumbnailTitleView(type: .simple)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .systemBlue
        self.contentView.addSubview(thumbnailView)
        
        thumbnailView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(16)
            make.horizontalEdges.equalToSuperview().inset(20)
        }
    }

    public func configure(with viewModel: ThumbnailViewModel?) {
        guard let viewModel = viewModel else { return }
        thumbnailView.configure(with: viewModel)
    }
}
