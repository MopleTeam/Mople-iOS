//
//  PhotoCollectionView.swift
//  Mople
//
//  Created by CatSlave on 2/5/25.
//

import UIKit
import RxSwift
import RxRelay

final class PhotoCollectionView: UIView {
    
    private let lineSpacing: CGFloat = 4
    private let cellColumns: CGFloat = 3
    private var images: [UIImage] = []
    private var maxPhotoCount: Int = 5
    fileprivate var isEditMode: Bool
    
    fileprivate let cellSelectedRelay: PublishRelay<Int> = .init()
    fileprivate let addButtonRelay: PublishRelay<Void> = .init()
    fileprivate let deleteButtonRelay: PublishRelay<Int> = .init()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .defaultWhite
        return collectionView
    }()
    
    init(isEditMode: Bool = false) {
        self.isEditMode = isEditMode
        super.init(frame: .zero)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        setCollectionView()
        setLayout()
    }
    
    private func setCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(PhotoCollectionCell.self,
                                forCellWithReuseIdentifier: PhotoCollectionCell.reuseIdentifier)
        collectionView.register(PhotoCollectionHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PhotoCollectionHeaderView.reuseIdentifier)
    }
    
    private func setLayout() {
        self.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    public func setImage(images: [UIImage]) {
        self.images = images
        self.collectionView.reloadData()
    }
}

extension PhotoCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionCell.reuseIdentifier,
            for: indexPath) as! PhotoCollectionCell
        cell.configure(image: images[indexPath.item])
        
        if isEditMode {
            cell.setEditMode()
            cell.deleteButtonTapped = { [weak self] in
                self?.deleteButtonRelay.accept(indexPath.item)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PhotoCollectionHeaderView.reuseIdentifier, for: indexPath) as! PhotoCollectionHeaderView
            headerView.addButtonTapped = { [weak self] in
                self?.addButtonRelay.accept(())
            }
            return headerView
        } else {
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard isEditMode else { return .zero }
        var cellSize = getCellSize()
        cellSize.width += 20
        let canAddPhoto = images.count < maxPhotoCount
        return canAddPhoto ? cellSize : .zero
    }
}

extension PhotoCollectionView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.cellSelectedRelay.accept(indexPath.item)
    }
}

extension PhotoCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return getCellSize()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let canAddPhoto = images.count < maxPhotoCount
        let leftInset: CGFloat = isEditMode && canAddPhoto ? lineSpacing : 20
        return UIEdgeInsets(top: 20, left: leftInset, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}

extension PhotoCollectionView {
    private func getCellSize() -> CGSize {
        let spaceWidth = collectionView.bounds.width - 40
        let spaceHeight = collectionView.bounds.height - 40
        let cellWidth = (spaceWidth - (lineSpacing * (cellColumns - 1))) / cellColumns
        return CGSize(width: cellWidth, height: spaceHeight)
    }
}

extension Reactive where Base: PhotoCollectionView {
    var selectPhoto: Observable<Int> {
        
        return base.cellSelectedRelay.asObservable()
            .do(onNext: { _ in
                print(#function, #line)
            })
            .filter { [weak base] _ in
                base?.isEditMode == false
            }
   
    }
    
    var appPhotos: Observable<Void> {
        return base.addButtonRelay.asObservable()
            .filter { [weak base] _ in
                base?.isEditMode == true
            }
    }
    
    var deletePhotos: Observable<Int> {
        return base.deleteButtonRelay.asObservable()
            .filter { [weak base] _ in
                base?.isEditMode == true
            }
    }
}
