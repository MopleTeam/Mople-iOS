//
//  PhotoCollectionCell.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//
import UIKit
import RxSwift
import RxCocoa
import Kingfisher

final class PhotoCollectionCell: UICollectionViewCell {
    
    var deleteButtonTapped: (() -> Void)?
   
    private var disposeBag = DisposeBag()
    
    private var task: DownloadTask?
    
    private var isEditMode: Bool = false
    
    #warning("뷰에 버튼 추가 시 동작하지 않는 문제 해결")
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.makeLine(width: 1)
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var photoOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultBlack.withAlphaComponent(0.4)
        return view
    }()
    
    private lazy var deleteButtton: UIButton = {
        let button = UIButton()
        button.setImage(.circleClose, for: .normal)
        return button
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
        disposeBag = DisposeBag()
    }
    
    private func setLayout() {
        self.contentView.addSubview(imageView)

        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        deleteButtton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.deleteButtonTapped?()
            })
            .disposed(by: disposeBag)
    }
}

extension PhotoCollectionCell {
    public func configure(image: UIImage) {
        imageView.image = image
    }
    
    public func setEditMode() {
        self.isEditMode = true
        addEditView()
        bind()
    }
    
    private func addEditView() {
        imageView.addSubview(photoOverlayView)
        photoOverlayView.addSubview(deleteButtton)
        
        photoOverlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(1)
        }
        
        deleteButtton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(7)
            make.size.equalTo(24)
        }
    }
}
