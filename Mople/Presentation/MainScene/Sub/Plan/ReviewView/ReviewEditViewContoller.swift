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

final class ReviewEditViewContoller: TitleNaviViewController, View {
    
    typealias Reactor = ReviewEditViewReactor
    
    var disposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = false
        return view
    }()
    
    private let contentView = UIView()
    
    private let titleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.Default.white
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.text = "만족스러운 약속이셨나요?\n사진을 남겨 추억을 나눠보세요"
        label.textColor = ColorStyle.Gray._01
        label.font = FontStyle.Heading.bold
        return label
    }()
    
    private let countView = CountView(title: "함께한 순간")
    
    private let reviewImageView = PhotoCollectionView(isEditMode: true)
    
    private let planInfoView = PlanInfoView(hasMapView: false)
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [countView, reviewImageView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.Default.white
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleContainer, subStackView, planInfoView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.BG.secondary
        
        return sv
    }()
    
    private let completeButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: "후기 작성하기",
                     font: FontStyle.Title3.semiBold,
                     normalColor: ColorStyle.Default.white)
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       disabledColor: ColorStyle.Primary.disable)
        btn.setRadius(8)
        btn.rx.isEnabled.onNext(false)
        return btn
    }()
    
    init(title: String,
         reactor: ReviewEditViewReactor) {
        super.init(title: title)
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initalSetup()
    }
    
    private func initalSetup() {
        setupLayout()
        setNaviItem()
    }
    
    private func setupLayout() {
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
            make.bottom.equalToSuperview().inset(UIScreen.getBottomSafeAreaHeight())
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }
    
    func bind(reactor: ReviewEditViewReactor) {
        naviBar.leftItemEvent
            .map { Reactor.Action.endFlow }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$review)
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, review in
                vc.countView.countText = "\(review.images.count)개"
                vc.reviewImageView.setImagePaths(review.images)
                vc.planInfoView.configure(with: .init(review: review))
            })
            .disposed(by: disposeBag)
        
        reviewImageView.rx.appPhotos
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                print(#function, #line, "사진 추가 탭" )
            })
            .disposed(by: disposeBag)
        
        reviewImageView.rx.selectPhoto
            .subscribe(with: self, onNext: { vc, _ in
                print(#function, #line, "사진 탭" )
            })
            .disposed(by: disposeBag)
        
        reviewImageView.rx.deletePhotos
            .subscribe(with: self, onNext: { vc, _ in
                print(#function, #line, "사진 삭제 탭" )
            })
            .disposed(by: disposeBag)
    }
}
