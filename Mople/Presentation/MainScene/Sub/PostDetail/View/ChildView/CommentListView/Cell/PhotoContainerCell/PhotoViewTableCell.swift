//
//  PhotoContainerCell.swift
//  Mople
//
//  Created by CatSlave on 1/24/25.
//

import UIKit
import RxSwift

final class PhotoViewTableCell: UITableViewCell {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Closure
    var photoTapped: ((Int) -> Void)?

    // MARK: - UI Components
    private let photoView = PhotoCollectionView()

    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(photoView)
        
        photoView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Action
    private func setAction() {
        photoView.rx.selectPhoto
            .subscribe(with: self, onNext: { vc, index in
                vc.photoTapped?(index)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Configure
    public func configure(_ images: [UIImage]) {
        self.photoView.setImage(images: images)
    }
}

