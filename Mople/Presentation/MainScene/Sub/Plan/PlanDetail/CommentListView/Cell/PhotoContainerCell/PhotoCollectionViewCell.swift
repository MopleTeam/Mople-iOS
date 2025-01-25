//
//  PhotoContainerCell.swift
//  Mople
//
//  Created by CatSlave on 1/24/25.
//

import UIKit

final class PhotoCollectionViewCell: UITableViewCell {
        
    private let lineSpacing: CGFloat = 4
    private let cellColumns: CGFloat = 3
    private var imagePaths: [String?] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = ColorStyle.Default.white
        return collectionView
    }()
    
    override init(style: UITableViewCell.CellStyle,
         reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        setCollectionView()
        setLayout()
    }
    
    private func setCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        collectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.reuseIdentifier)
    }
    
    private func setLayout() {
        self.contentView.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    public func setImagePaths(_ imagePaths: [String?]) {
        self.imagePaths = imagePaths
        self.collectionView.reloadData()
    }
}

extension PhotoCollectionViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionCell.reuseIdentifier,
            for: indexPath) as! PhotoCollectionCell
        cell.configure(imagePath: imagePaths[indexPath.item])
        return cell
    }
}

extension PhotoCollectionViewCell: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let spaceWidth = collectionView.bounds.width - 40
        let spaceHeight = collectionView.bounds.height - 40
        let cellWidth = (spaceWidth - (lineSpacing * (cellColumns - 1))) / cellColumns
        return CGSize(width: cellWidth, height: spaceHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return lineSpacing
    }
}
