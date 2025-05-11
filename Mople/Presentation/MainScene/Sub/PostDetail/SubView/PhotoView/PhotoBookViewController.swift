//
//  PhotoViewController.swift
//  Mople
//
//  Created by CatSlave on 2/14/25.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoBookViewController: TitleNaviViewController {
    
    // MARK: - Coordinator
    private weak var coordinator: NavigationCloseable?
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    private let imagePaths: [String]
    private let startIndex: Int
    private var isStart: Bool = false
    
    // MARK: - UI Components
    private let indicatorLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.semiBold
        label.textColor = .gray04
        label.layer.zPosition = 2
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.backgroundColor = .defaultBlack
        return collectionView
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         imagePaths: [String],
         selectedIndex: Int,
         coordinator: NavigationCloseable) {
        self.imagePaths = imagePaths
        self.startIndex = selectedIndex
        super.init(screenName: screenName,
                   title: title)
        self.coordinator = coordinator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAction()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setStartIndexPage()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setCollectionView()
        setLayout()
        setNavi()
    }
    
    private func setCollectionView() {
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        collectionView.register(PhotoBookCollectionCell.self,
                                forCellWithReuseIdentifier: PhotoBookCollectionCell.reuseIdentifier)
    }
    
    private func setNavi() {
        self.naviBar.setBarItem(type: .left,
                                image: .backArrow.withTintColor(.defaultWhite))
    }
    
    private func setLayout() {
        setBlackBackground()
        self.view.addSubview(collectionView)
        self.view.addSubview(indicatorLabel)
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom).offset(40)
            make.bottom.equalToSuperview().inset(150)
            make.horizontalEdges.equalToSuperview()
        }
        
        indicatorLabel.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.centerY.equalTo(naviBar)
            make.trailing.equalTo(naviBar).inset(20)
        }
    }
    
    private func setStartIndexPage() {
        guard isStart == false else { return }
        collectionView.scrollToItem(at: .init(row: startIndex,
                                              section: 0),
                                    at: .centeredHorizontally,
                                    animated: false)
        setIndicatorLabel(startIndex + 1)
        isStart = true
    }
    
    // MARK: - Action
    private func setAction() {
        self.naviBar.leftItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.coordinator?.pop()
            })
            .disposed(by: disposeBag)
    }
}

extension PhotoBookViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        imagePaths.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoBookCollectionCell.reuseIdentifier,
            for: indexPath) as! PhotoBookCollectionCell
        cell.setPhoto(imagePaths[indexPath.item])
        return cell
    }
}

extension PhotoBookViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spaceWidth = collectionView.bounds.width
        let spaceHeight = collectionView.bounds.height
        return CGSize(width: spaceWidth, height: spaceHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - 페이지 인디케이터 설정
extension PhotoBookViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffsetY = scrollView.contentOffset.x
        let scrollViewWidth = scrollView.bounds.width
        let index = Int(contentOffsetY / scrollViewWidth)
        let pageIndex = index + 1
        setIndicatorLabel(pageIndex)
    }
    
    private func setIndicatorLabel(_ pageIndex: Int) {
        indicatorLabel.text = "\(pageIndex)/\(imagePaths.count)"
    }
}


