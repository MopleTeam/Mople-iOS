//
//  PhotoBookCollectionCell.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import UIKit

final class PhotoBookCollectionCell: UICollectionViewCell {
    
    // MARK: - UI Componentns
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.maximumZoomScale = 5.0
        return view
    }()
    
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
        setScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(scrollView)
        self.scrollView.addSubview(imageView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
        }
    }
    
    private func setScrollView() {
        self.scrollView.delegate = self
    }
    
    public func setPhoto(_ path: String) {
        imageView.kfSetimage(path,
                             defaultImageType: .history)
    }
}

extension PhotoBookCollectionCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

