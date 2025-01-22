//
//  PhotoListViewController.swift
//  Mople
//
//  Created by CatSlave on 1/21/25.
//

import UIKit
import RxSwift
import ReactorKit
import RxCocoa

final class PhotoListViewController: BaseViewController, View {
    
    typealias Reactor = PhotoListViewReactor
    
    var disposeBag = DisposeBag()
    
    private let lineSpacing: CGFloat = 4
    private let cellColumns: CGFloat = 3
    
    private let countView: CountView = {
        let view = CountView(title: "함께한 순간")
        view.setTitleFont(font: FontStyle.Title3.semiBold,
                          textColor: ColorStyle.Gray._01)
        view.setCountFont(font: FontStyle.Title3.semiBold,
                          textColor: ColorStyle.Gray._04)
        return view
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    init(reactor: PhotoListViewReactor) {
        super.init()
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCollectionView()
        setLayout()
    }
    
    private func setCollectionView() {
        self.collectionView.delegate = self
        collectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.reuseIdentifier)
    }
    
    private func setLayout() {
        self.view.addSubview(countView)
        self.view.addSubview(collectionView)
        
        countView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.height.equalTo(50)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(countView.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    func bind(reactor: PhotoListViewReactor) {
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        let loadImages = Observable.combineLatest(viewDidLayout, reactor.pulse(\.$imagePaths))
            .share()
            .map { $0.1 }
        
        loadImages
            .asDriver(onErrorJustReturn: [])
            .drive(self.collectionView.rx.items(cellIdentifier: PhotoCollectionCell.reuseIdentifier,
                                                cellType: PhotoCollectionCell.self)) { index, item, cell in
                cell.configure(imagePath: item)
            }
            .disposed(by: disposeBag)
        
        loadImages
            .map { $0.count }
            .asDriver(onErrorJustReturn: 0)
            .drive(with: self, onNext: { vc, count in
                vc.countView.countText = "\(count)개"
            })
            .disposed(by: disposeBag)
    }
}

extension PhotoListViewController: UICollectionViewDelegateFlowLayout {
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




