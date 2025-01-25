//
//  PhotoCollectionCell.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//
import UIKit
import Kingfisher

final class PhotoCollectionCell: UICollectionViewCell {
    
    private var task: DownloadTask?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.makeLine(width: 1)
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
    }
    
    private func setLayout() {
        self.contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func configure(imagePath: String?) {
        task = self.imageView.kfSetimage(imagePath,
                                         defaultImageType: .history)
    }
}
