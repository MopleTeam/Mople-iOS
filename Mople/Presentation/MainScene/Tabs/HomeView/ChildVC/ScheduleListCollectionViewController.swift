//
//  ScheduleCollectionViewController.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import RxDataSources

final class ScheduleListCollectionViewController: UIViewController, View {
    
    typealias Reactor = HomeViewReactor
    typealias Section = SectionModel<Void, SimpleSchedule>
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
    
    // MARK: - Observer
    private let footerTapObserver: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    // MARK: - LifeCycle
    init(reactor: HomeViewReactor) {
        print(#function, #line, "LifeCycle Test ScheduleListCollectionView Created" )
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test ScheduleListCollectionView Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        moveToLastItem()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setCollectionView() {
        self.collectionView.delegate = self
        collectionView.register(ScheduleCollectionCell.self, forCellWithReuseIdentifier: ScheduleCollectionCell.reuseIdentifier)
        collectionView.register(ScheduleListReuseFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ScheduleListReuseFooterView.reuseIdentifier)
    }
    
    // MARK: - DataSource
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<Section> {
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<Section>(
             configureCell: { _, collectionView, indexPath, item in
                 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScheduleCollectionCell.reuseIdentifier, for: indexPath) as! ScheduleCollectionCell
                 cell.configure(with: ScheduleViewModel(schedule: item))
                 return cell
             },
             configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
                 guard let self else { return UICollectionReusableView() }
                 if kind == UICollectionView.elementKindSectionFooter {
                     let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ScheduleListReuseFooterView.reuseIdentifier, for: indexPath) as! ScheduleListReuseFooterView
                     footer.setTapAction(on: self.footerTapObserver.asObserver())
                     return footer
                 } else {
                     return UICollectionReusableView()
                 }
             }
         )
        return dataSource
    }

    // MARK: - Binding
    func bind(reactor: HomeViewReactor) {
        let dataSource = configureDataSource()
        
        footerTapObserver
            .map({ _ in Reactor.Action.presentCalendaer })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$schedules)
            .map { [Section(model: (), items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension ScheduleListCollectionViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionView.horizontalSnapToItem(targetContentOffset: targetContentOffset,
                                          scrollView: scrollView,
                                          velocity: velocity)
    }
}

extension ScheduleListCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fullWidth = collectionView.bounds.width - 40
        let fullHeight = collectionView.bounds.height
                
        return CGSize(width: fullWidth, height: fullHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let fullHeight = collectionView.bounds.height
        return CGSize(width: 109, height: fullHeight)
    }
    
    #warning("참고")
    // 컬렉션 뷰 레이아웃 조정
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

// MARK: - 컨텐츠 위치 체크
extension ScheduleListCollectionViewController {
    
    private func hasReachedBottom() -> Bool {
        guard collectionView.contentWidth != 0 else { return false }
        return collectionView.offsetMaxX == collectionView.contentWidth
    }
    
    private func moveToLastItem() {
        guard hasReachedBottom(),
              let lastItem = collectionView.indexPathsForVisibleItems.last else { return }
        
        collectionView.selectItem(at: lastItem, animated: false, scrollPosition: .centeredHorizontally)
    }
}

