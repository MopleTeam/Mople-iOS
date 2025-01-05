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
    typealias Reactor = DetailMeetViewReactor
    
    var disposeBag: DisposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        view.backgroundColor = ColorStyle.BG.primary
        return view
    }()
    
    private let contentView = UIView()
    
    private let thumnailView: ThumbnailTitleView = {
        let view = ThumbnailTitleView(type: .detail(size: .large))
        return view
    }()
    
    private let segment = CustomSegmentedControl()
    
    private lazy var headerStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [thumnailView, segment])
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
    
    private(set) var pageContainer = UIView()
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
         reactor: DetailMeetViewReactor) {
        print(#function, #line, "LifeCycle Test DetailGroupViewController Created" )
        super.init(title: title)
        self.reactor = reactor
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DetailGroupViewController Deinit" )
    }
    
    private func initalizeSetup() {
        setLayout()
        setupNavi()
    }
    
    private func setLayout() {
        self.add(child: pageController, container: pageContainer)
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(headerStackView)
        self.contentView.addSubview(pageContainer)
            
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        headerStackView.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
        }
        
        segment.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        pageContainer.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(500)
        }
    }
    
    private func setupNavi() {
        self.setBarItem(type: .left)
        self.setBarItem(type: .right, image: .list)
    }
    
    func bind(reactor: DetailMeetViewReactor) {
        [self.segment.rx.nextTap, self.segment.rx.previousTap].forEach({
            $0.map({ Reactor.Action.switchPage(isFuture: $0)
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag) })
        
        reactor.pulse(\.$meet)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, meet in
                vc.thumnailView.configure(with: .init(meet: meet))
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
}


