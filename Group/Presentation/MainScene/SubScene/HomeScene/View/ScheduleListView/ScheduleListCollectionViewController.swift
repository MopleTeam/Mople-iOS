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
    
    typealias Reactor = ScheduleViewReactor
    
    var disposeBag = DisposeBag()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    init(reactor: ScheduleViewReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setCollectionView()
    }
    
    private func setupUI() {
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setCollectionView() {
        self.collectionView.delegate = self
        collectionView.register(ScheduleListCell.self, forCellWithReuseIdentifier: ScheduleListCell.reuseIdentifier)
        collectionView.register(ScheduleListReuseFooterView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: ScheduleListReuseFooterView.reuseIdentifier)
    }
    
    typealias Section = SectionModel<Void, Schedule>
    
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<Section> {
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<Section>(
             configureCell: { _, collectionView, indexPath, item in
                 let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScheduleListCell.reuseIdentifier, for: indexPath) as! ScheduleListCell
                 cell.configure(viewModel: ScheduleListItemViewModel(schedule: item))
                 return cell
             },
             configureSupplementaryView: { _, collectionView, kind, indexPath in
                 if kind == UICollectionView.elementKindSectionFooter {
                     return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ScheduleListReuseFooterView.reuseIdentifier, for: indexPath) as! ScheduleListReuseFooterView
                 } else {
                     return UICollectionReusableView()
                 }
             }
         )
        return dataSource
    }
    
    #warning("학습 필요")
    func bind(reactor: ScheduleViewReactor) {
        let dataSource = configureDataSource()
        
        reactor.pulse(\.$schedules)
            .map { [Section(model: (), items: $0)] }
            .asDriver(onErrorJustReturn: [])
            .drive(self.collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)
    }
}

extension ScheduleListCollectionViewController: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        collectionView.verticalSnapToItem(targetContentOffset: targetContentOffset,
                                          scrollView: scrollView,
                                          velocity: velocity)
    }
}

extension ScheduleListCollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let fullWidth = collectionView.bounds.width - 40
        let fullHeight = collectionView.bounds.height
        
        print("ifno path: \(fullHeight)")
        
        return CGSize(width: fullWidth, height: fullHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let fullHeight = collectionView.bounds.height
        
        return CGSize(width: 89, height: fullHeight)
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

