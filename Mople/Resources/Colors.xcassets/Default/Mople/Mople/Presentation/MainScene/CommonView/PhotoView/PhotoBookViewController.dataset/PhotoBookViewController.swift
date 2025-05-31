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
    private let defaultImageType: UIImageView.DefaultImageType
    private var isHideNaviBar: Bool = false
    private let opacity: CGFloat = 0.5
    public var selectedIndex: Int = 0
    public var isViewStarted: Bool = false
    
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
    
    // MARK: - Gestrue
    private let tapGesture: UITapGestureRecognizer = .init()
    private let panGesture: UIPanGestureRecognizer = .init()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         imagePaths: [String],
         defaultImageType: UIImageView.DefaultImageType,
         coordinator: NavigationCloseable) {
        self.imagePaths = imagePaths
        self.defaultImageType = defaultImageType
        super.init(screenName: screenName,
                   initiallyNavigationBar: false,
                   title: title)
        self.coordinator = coordinator
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        self.modalTransitionStyle = .coverVertical
        self.modalPresentationStyle = .overFullScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setAction()
        setGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollToSelectedIndex()
        isViewStarted = true
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setCollectionView()
        setLayout()
        setNavi()
        setIndicatorLabel()
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
        self.view.addSubview(collectionView)
        self.naviBar.addSubview(indicatorLabel)
        setBackgroundColor()
        addNaviBar()
        
        collectionView.snp.makeConstraints { make in
            make.horizontalEdges.height.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        indicatorLabel.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.centerY.equalToSuperview()
            make.trailing.equalTo(naviBar).inset(20)
        }
    }
    
    private func setBackgroundColor() {
        self.view.backgroundColor = .defaultBlack.withAlphaComponent(opacity)
        notchView.backgroundColor = .defaultBlack.withAlphaComponent(opacity)
        naviBar.backgroundColor = .defaultBlack.withAlphaComponent(opacity)
        naviBar.setTitleColor(.defaultWhite)
    }
    
    private func scrollToSelectedIndex() {
        let maxCount = collectionView.numberOfItems(inSection: 0)
        guard !isViewStarted,
              selectedIndex != 0,
              selectedIndex < maxCount else { return }
        collectionView.scrollToItem(at: .init(row: selectedIndex,
                                              section: 0),
                                    at: .centeredHorizontally,
                                    animated: false)
    }
    
    // MARK: - Set Gesture
    private func setGesture() {
        setPanGesture()
        setTapGesture()
    }
    
    private func setPanGesture() {
        self.view.addGestureRecognizer(panGesture)
        panGesture.delegate = self
        
        panGesture.rx.event
            .subscribe(with: self, onNext: { vc, event in
                vc.handlePanGesture(event)
            })
            .disposed(by: disposeBag)
    }
    
    private func setTapGesture() {
        self.view.addGestureRecognizer(tapGesture)
        tapGesture.delegate = self
        
        tapGesture.rx.event
            .subscribe(with: self, onNext: { vc, event in
                vc.handleTopHideWithAnimation(isHide: !vc.isHideNaviBar)
                vc.isHideNaviBar.toggle()
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Handle PanGesture
    private func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        let velocityY = panGesture.velocity(in: self.view).y
        let translationY = panGesture.translation(in: self.view).y
        let viewHeight = view.frame.height
        let adjustOpacity = opacity - opacity * (translationY / viewHeight)
        
        switch panGesture.state {
        case .began:
            handlePanGestureBegen()
        case .changed:
            handlePanGestureChanged(translationY: translationY,
                                    opacity: adjustOpacity)
        case .ended:
            handlePanGestureEnded(translationY: translationY,
                                  velocityY: velocityY)
        default:
            break
        }
    }
    
    private func handlePanGestureBegen() {
        moveTopOutOfView()
        hideTop(isHide: true)
    }
    
    private func handlePanGestureChanged(translationY: CGFloat,
                                         opacity: CGFloat) {
        guard translationY > 0 else { return }
        changeOpacity(opacity: opacity)
        changeBottomOffset(offset: translationY)
    }

    private func handlePanGestureEnded(translationY: CGFloat,
                                       velocityY: CGFloat) {
        let viewHalfHeight = self.view.frame.height / 2
        if translationY > viewHalfHeight || velocityY > 300 {
            dismiss()
        } else {
            cancelDismiss()
        }
    }
    
    private func dismiss() {
        UIView.animate(
            withDuration: 0.33,
            animations: {[weak self] in
                guard let self else { return }
                self.changeBottomOffset(offset: self.view.frame.height)
                self.changeOpacity(opacity: 0)
                self.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.coordinator?.dismiss(completion: nil)
            })
    }
    
    private func cancelDismiss() {
        UIView.animate(
            withDuration: 0.33,
            animations: {[weak self] in
                guard let self else { return }
                self.changeBottomOffset(offset: 0)
                self.changeOpacity(opacity: opacity)
                self.view.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.hideTop(isHide: false)
                self?.handleTopHideWithAnimation(isHide: false)
            })
    }
    
    // 뷰 내림 정도 조정
    private func changeBottomOffset(offset: CGFloat) {
        collectionView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(offset)
        }
    }
    
    // 배경 투명도 조정
    private func changeOpacity(opacity: CGFloat) {
        let backColor: UIColor = .defaultBlack
        self.view.backgroundColor = backColor.withAlphaComponent(opacity)
    }
    
    
    
    // MARK: - Handle TapGesture
    private func handleTopHideWithAnimation(isHide: Bool) {
        UIView.animate(
            withDuration: 0.33,
            animations: { [weak self] in
                if isHide {
                    self?.moveTopOutOfView()
                } else {
                    self?.moveTopIntoView()
                }
                self?.view.layoutIfNeeded()
            })
    }
    
    // MARK: - Action
    private func setAction() {
        self.naviBar.leftItemEvent
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.coordinator?.dismiss(completion: nil)
            })
            .disposed(by: disposeBag)
    }
}

extension PhotoBookViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let gestureLocation = gestureRecognizer.location(in: self.view)
        return !naviBar.frame.contains(gestureLocation)
    }
}

extension PhotoBookViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return max(imagePaths.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoBookCollectionCell.reuseIdentifier,
            for: indexPath) as! PhotoBookCollectionCell
        
        let imagePath = imagePaths[safe: indexPath.item]
        cell.setPhoto(imagePath,
                      defaultImageType: defaultImageType)
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
        setIndicatorLabel(index)
    }
    
    private func setIndicatorLabel(_ pageIndex: Int = 0) {
        if imagePaths.count > 1 {
            indicatorLabel.text = "\(pageIndex + 1)/\(imagePaths.count)"
        } else {
            indicatorLabel.isHidden = true
        }
    }
}


