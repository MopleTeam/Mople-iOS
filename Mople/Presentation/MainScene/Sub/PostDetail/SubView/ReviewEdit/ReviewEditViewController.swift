//
//  ReviewViewContoller.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//

import UIKit
import SnapKit
import RxCocoa
import ReactorKit

final class ReviewEditViewController: TitleNaviViewController, View {
    
    // MARK: - Reactor
    typealias Reactor = ReviewEditViewReactor
    var disposeBag = DisposeBag()
    
    // MARK: - Observable
    private let endFlow: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let titleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultWhite
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = L10n.Createreview.header
        label.textColor = .gray01
        label.font = FontStyle.Heading.bold
        return label
    }()
    
    private let countView = CountView(title: L10n.Review.photoHeader)
    
    private let reviewImageView = PhotoCollectionView(isEditMode: true)
    
    private let planInfoView = PostInfoView(type: .basic)
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [countView, reviewImageView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = .defaultWhite
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleContainer, subStackView, planInfoView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = .bgSecondary
        return sv
    }()
    
    private let completeButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: L10n.Createreview.complete,
                     font: FontStyle.Title3.semiBold,
                     normalColor: .defaultWhite)
        btn.setBgColor(normalColor: .appPrimary,
                       disabledColor: .disablePrimary)
        btn.setRadius(8)
        btn.rx.isEnabled.onNext(false)
        return btn
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         title: String?,
         reactor: ReviewEditViewReactor) {
        super.init(screenName: screenName,
                   title: title)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setEdgeGesture()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setNaviItem()
        setLayout()
    }
    
    private func setLayout() {
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(mainStackView)
        self.contentView.addSubview(completeButton)
        self.titleContainer.addSubview(titleLabel)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.bottom.horizontalEdges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
            make.height.greaterThanOrEqualTo(scrollView.frameLayoutGuide.snp.height)
        }
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.lessThanOrEqualTo(completeButton.snp.top)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        subStackView.snp.makeConstraints { make in
            make.height.equalTo(207)
        }
        
        reviewImageView.snp.makeConstraints { make in
            make.height.equalTo(149)
        }
        
        completeButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(mainStackView).inset(20)
            make.height.equalTo(56)
            make.bottom.equalToSuperview().inset(UIScreen.getDefaultBottomPadding())
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    // MARK: - Gesture
    private func setEdgeGesture() {
        guard let currentNavi = self.findCurrentNavigation(),
              let edgeGesture = currentNavi.interactivePopGestureRecognizer else { return }
        scrollView.panGestureRecognizer.require(toFail: edgeGesture)
    }
}

// MARK: - Reactor Setup
extension ReviewEditViewController {
    
    func bind(reactor: ReviewEditViewReactor) {
        inputBind(reactor)
        outputBind(reactor)
    }
    
    private func inputBind(_ reactor: Reactor) {
        setActionBind(reactor)
    }

    private func outputBind(_ reactor: Reactor) {
        self.rx.viewDidLoad
            .subscribe(with: self, onNext: { vc, _ in
                vc.setReactorStateBind(reactor)
            })
            .disposed(by: disposeBag)
    }

    private func setActionBind(_ reactor: Reactor) {
        naviBar.leftItemEvent
            .map { Reactor.Action.flow(.endView) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        endFlow
            .map { Reactor.Action.flow(.endFlow) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        planInfoView.rx.memberTapped
            .map { Reactor.Action.flow(.showMemberList) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reviewImageView.rx.appPhotos
            .map { Reactor.Action.showImagePicker }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reviewImageView.rx.deletePhotos
            .map { Reactor.Action.deleteImage($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completeButton.rx.controlEvent(.touchUpInside)
            .throttle(.seconds(1),
                      latest: false,
                      scheduler: MainScheduler.instance)
            .map { Reactor.Action.updateReview }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
    }
    
    private func setReactorStateBind(_ reactor: Reactor) {
        reactor.pulse(\.$review)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, review in
                let viewModel = ReviewPostSummary(review: review)
                vc.planInfoView.configure(with: viewModel)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$images)
            .asDriver(onErrorJustReturn: [])
            .map({
                $0.map { imageWrapper in
                    imageWrapper.image
                }
            })
            .drive(with: self, onNext: { vc, images in
                vc.reviewImageView.setImage(images: images)
                vc.countView.countText = L10n.itemCount(images.count)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$canComplete)
            .asDriver(onErrorJustReturn: false)
            .drive(completeButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$error)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }

    // MARK: - 에러 핸들링
    private func handleError(_ err: ReviewEditError) {
        switch err {
        case let .noResponse(err):
            alertManager.showResponseErrorMessage(err: err,
                                                 completion: { [weak self] in
                self?.endFlow.onNext(())
            })
        case let .failSelectPhoto(err):
            alertManager.showDefaultAlert(title: err.info,
                                   subTitle: err.subInfo)
        case .unknown:
            alertManager.showDefatulErrorMessage()
        }
    }
}

