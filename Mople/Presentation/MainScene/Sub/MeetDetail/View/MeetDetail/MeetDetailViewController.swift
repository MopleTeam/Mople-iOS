//
//  DetailGroupViewController.swift
//  Mople
//
//  Created by CatSlave on 1/5/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit

final class DetailMeetViewController: TitleNaviViewController, View {
    typealias Reactor = MeetDetailViewReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.BG.primary
        return view
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.App.stroke
        view.layer.makeCornes(radius: 16, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        return view
    }()
    
    private let thumbnailView: ThumbnailView = {
        let view = ThumbnailView(thumbnailSize: 56,
                                      thumbnailRadius: 12)
        view.addMemberCountLabel()
        view.setTitleLabel(font: FontStyle.Title2.semiBold,
                           color: ColorStyle.Gray._01)
        view.setSpacing(12)
        return view
    }()
    
    private let segment:DefaultSegmentedControl = {
        let segControl = DefaultSegmentedControl()
        return segControl
    }()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [thumbnailView, segment])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 24
        stackView.backgroundColor = ColorStyle.Default.white
        stackView.layer.makeShadow(opactity: 0.02, radius: 12, offset: .init(width: 0, height: 0))
        stackView.layer.makeCornes(radius: 16, corners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        return stackView
    }()
    
    private(set) var pageController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll,
                                        navigationOrientation: .horizontal)
        return pageVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalizeSetup()
    }
    
    init(title: String?,
         reactor: MeetDetailViewReactor?) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalizeSetup() {
        setLayout()
        setupNavi()
        setPageVC()
    }
    
    private func setLayout() {
        self.add(child: pageController)
        self.view.addSubview(contentView)
        self.contentView.addSubview(borderView)
        self.contentView.addSubview(headerStackView)
        self.contentView.addSubview(pageController.view)
        
        contentView.snp.makeConstraints { make in
            make.top.equalTo(self.titleViewBottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
            
        headerStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
 
        segment.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalTo(headerStackView).offset(1)
        }
        
        pageController.view.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.horizontalEdges.bottom.equalToSuperview()
        }
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
        self.setBarItem(type: .right, image: .list)
    }
    
    private func setPageVC() {
        self.pageController.delegate = self
    }
    
    func bind(reactor: MeetDetailViewReactor) {
        
        self.naviBar.leftItemEvent
            .map { Reactor.Action.endFlow }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.naviBar.rightItemEvent
            .map { Reactor.Action.pushMeetSetupView }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        [self.segment.rx.nextTap, self.segment.rx.previousTap].forEach({
            $0.map({ Reactor.Action.switchPage(isFuture: $0)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag) })
        
        let viewDidLayout = self.rx.viewDidLayoutSubviews
            .take(1)
        
        Observable.combineLatest(viewDidLayout, reactor.pulse(\.$meet))
            .map({ $0.1 })
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, meet in
                vc.thumbnailView.configure(with: .init(meet: meet))
            })
            .disposed(by: disposeBag)
        
        Observable.merge(reactor.pulse(\.$meetInfoLoaded),
                         reactor.pulse(\.$futurePlanLoaded),
                         reactor.pulse(\.$pastPlanLoaded))
        .skip(1)
        .observe(on: MainScheduler.instance)
        .filter { [weak self] isLoad in
            self?.indicator.isAnimating == false && isLoad == true
        }
        .map({ _ in true })
        .bind(to: self.rx.isLoading)
        .disposed(by: disposeBag)
        
        Observable.combineLatest(reactor.pulse(\.$meetInfoLoaded),
                                 reactor.pulse(\.$futurePlanLoaded),
                                 reactor.pulse(\.$pastPlanLoaded))
        .skip(1)
        .observe(on: MainScheduler.instance)
        .filter({ meetInfoLoaded, futurePlanLoaded, pastPlanLoaded in
            meetInfoLoaded == false &&
            futurePlanLoaded == false &&
            pastPlanLoaded == false
        })
        .map({ _ in false })
        .bind(to: self.rx.isLoading)
        .disposed(by: disposeBag)
            
    }
}
extension DetailMeetViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print(#function, #line, "#3" )
    }
}


