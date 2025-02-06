//
//  PhotoContainerCell.swift
//  Mople
//
//  Created by CatSlave on 1/24/25.
//

import UIKit

final class PhotoViewTableCell: UITableViewCell {

    private let photoView = PhotoCollectionView()

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setLayout() {
        self.contentView.addSubview(photoView)
        
        photoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func configure(_ imagePaths: [String]) {
        self.photoView.setImagePaths(imagePaths)
    }
}

