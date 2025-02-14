//
//  PhotoContainerCell.swift
//  Mople
//
//  Created by CatSlave on 1/24/25.
//

import UIKit
import RxSwift

final class PhotoViewTableCell: UITableViewCell {
    
    private var disposeBag = DisposeBag()
    
    var photoTapped: ((Int) -> Void)?

    private let photoView = PhotoCollectionView()

    override init(style: UITableViewCell.CellStyle,
                  reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setLayout()
        bind()
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
    
    private func bind() {
        photoView.rx.selectPhoto
            .do(onNext: { _ in
                print(#function, #line, "탭탭" )
            })
            .subscribe(with: self, onNext: { vc, index in
                vc.photoTapped?(index)
            })
            .disposed(by: disposeBag)
    }
    
    public func configure(_ images: [UIImage]) {
        self.photoView.setImage(images: images)
    }
}

