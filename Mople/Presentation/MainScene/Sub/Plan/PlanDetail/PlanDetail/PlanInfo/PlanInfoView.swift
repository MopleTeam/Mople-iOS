//
//  PlanDetailHeaderView.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PlanInfoView: UIView {
    
    typealias Reactor = PlanDetailViewReactor
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
    
    private var location: Location?
    
    private let height: CGFloat = 399

    // MARK: - UI Components
    private let thumbnailView: ThumbnailView = {
        let view = ThumbnailView(thumbnailSize: 20,
                                 thumbnailRadius: 6)
        view.setSpacing(8)
        view.setTitleLabel(font: FontStyle.Body2.semiBold,
                           color: ColorStyle.Gray._04)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Heading.bold
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    fileprivate let membersButton: UIButton = {
        let btn = UIButton()
        btn.setContentHuggingPriority(.required, for: .vertical)
        return btn
    }()
    
    private let countInfoLabel: IconLabel = {
        let label = IconLabel(icon: .member,
                              iconSize: .init(width: 24, height: 24))
        label.setTitleTopPadding(4)
        return label
    }()
    
    private let selectImage: UIImageView = {
        let view = UIImageView(image: .listArrow)
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let dateInfoLabel: IconLabel = {
        let label = IconLabel(icon: .date,
                              iconSize: .init(width: 24, height: 24))
        label.setTitleTopPadding(4)
        return label
    }()
    
    private let placeInfoLabel: IconLabel = {
        let label = IconLabel(icon: .place,
                              iconSize: .init(width: 24, height: 24))
        label.setTitleTopPadding(4)
        return label
    }()

    private let mapView: MapView = {
        let view = MapView()
        view.layer.cornerRadius = 8
        view.layer.makeLine(width: 1)
        view.backgroundColor = ColorStyle.BG.input
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, titleLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 12
        return sv
    }()
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [membersButton, dateInfoLabel, placeInfoLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .leading
        sv.spacing = 4
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStackView, subStackView, mapView])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 16
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 28, right: 20)
        sv.backgroundColor = ColorStyle.Default.white
        return sv
    }()
    
    // MARK: - Gesture
    fileprivate let mapTapGesture = UITapGestureRecognizer()
    
    // MARK: - LifeCycle
    init() {
        super.init(frame: .init(origin: .zero,
                                size: .init(width: 0,
                                            height: height)))
        initalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        setLayout()
        setInfoLabel()
        setMapTapGesture()
    }
    
    // MARK: - UI Setup
    private func setLayout() {
        self.addSubview(mainStackView)
        self.membersButton.addSubview(countInfoLabel)
        self.membersButton.addSubview(selectImage)
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().priority(.high)
            make.bottom.equalToSuperview().priority(.high)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(31)
        }
        
        [membersButton, dateInfoLabel].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(24)
            }
        }
        
        placeInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        countInfoLabel.snp.makeConstraints { make in
            make.leading.verticalEdges.equalToSuperview()
        }
        
        selectImage.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.leading.equalTo(countInfoLabel.snp.trailing).offset(4)
            make.centerY.equalToSuperview()
        }
        
        mapView.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
    }
    
    private func setInfoLabel() {
        [countInfoLabel, dateInfoLabel, placeInfoLabel].forEach {
            $0.setTitle(font: FontStyle.Body1.medium, color: ColorStyle.Gray._03)
            $0.setSpacing(4)
        }
    }
    
    private func setMapTapGesture() {
        mapView.addGestureRecognizer(mapTapGesture)
    }

    public func configure(with plan: PlanInfoViewModel) {
        print(#function, #line)
        thumbnailView.configure(with: .init(meetSummary: plan.meet))
        titleLabel.text = plan.name
        dateInfoLabel.text = plan.dateString
        countInfoLabel.text = plan.participantsCountText
        placeInfoLabel.text = plan.fullAddress
        mapView.initializeMap(location: plan.location ?? .defaultLocation)
    }
}

extension Reactive where Base: PlanInfoView {
    var memberTapped: ControlEvent<Void> {
        return base.membersButton.rx.controlEvent(.touchUpInside)
    }
    
    var mapTapped: Observable<Void> {
        return base.mapTapGesture.rx.event
            .map { _ in }
    }
}
