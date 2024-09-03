//
//  ScheduleCollectionViewController.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit

final class ScheduleListCollectionViewController: UIViewController {
    lazy var collectionView: UICollectionView = {
        
        // CollectionView 생성 시 FlowLayout 생성 필수
        //
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 8
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.contentInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        collectionView.backgroundColor = .clear
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    private func setupUI() {
        view.addSubview(collectionView)
        self.collectionView.delegate = self
        collectionView.register(ScheduleListCell.self, forCellWithReuseIdentifier: ScheduleListCell.reuseIdentifier)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension ScheduleListCollectionViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionView.verticalSnapToItem(targetContentOffset: targetContentOffset, scrollView: scrollView, velocity: velocity)
    }
}

extension ScheduleListCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fullWidth = collectionView.bounds.width - 40
        let fullHeight = collectionView.bounds.height
        
        return CGSize(width: fullWidth, height: fullHeight)
    }
}
