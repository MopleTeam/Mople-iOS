//
//  PhotoBookCollectionCell.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import UIKit

final class PhotoBookCollectionCell: UICollectionViewCell {
    
    // MARK: - UI Componentns
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func setPhoto(_ path: String) {
        imageView.kfSetimage(path,
                             defaultImageType: .history)
    }
}

