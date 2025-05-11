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

enum PostInfoType {
    case basic
    case plan
    case review
}

final class PostInfoView: UIView {
    
    // MARK: - Variables
    private let type: PostInfoType

    // MARK: - UI Components
    private let thumbnailView: ThumbnailView = {
        let view = ThumbnailView(thumbnailSize: 20,
                                 thumbnailRadius: 6)
        view.setSpacing(8)
        view.setTitleLabel(font: FontStyle.Body2.semiBold,
                           color: .gray04)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Heading.bold
        label.textColor = .gray01
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
        label.isUserInteractionEnabled = false
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

    private lazy var mapView: MapView = {
        let view = MapView()
        view.layer.cornerRadius = 8
        view.layer.makeLine(width: 1)
        view.backgroundColor = .bgInput
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    fileprivate lazy var participationButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Body1.semiBold,
                     normalColor: .defaultWhite,
                     selectedColor: .gray03)
        btn.setBgColor(normalColor: .appPrimary,
                       selectedColor: .appTertiary)
        btn.setRadius(8)
        return btn
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
        let sv = UIStackView(arrangedSubviews: [headerStackView, subStackView])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 16
        sv.isUserInteractionEnabled = true
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 28, right: 20)
        sv.backgroundColor = .defaultWhite
        return sv
    }()
    
    // MARK: - Gesture
    fileprivate lazy var mapTapGesture = UITapGestureRecognizer()
    
    // MARK: - LifeCycle
    init(type: PostInfoType) {
        self.type = type
        super.init(frame: .zero)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        setLayout()
        setInfoLabel()
        handleViewType()
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
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
    
    private func setInfoLabel() {
        [countInfoLabel, dateInfoLabel, placeInfoLabel].forEach {
            $0.setTitle(font: FontStyle.Body1.medium, color: .gray03)
            $0.setSpacing(4)
        }
    }
    
    private func handleViewType() {
        switch type {
        case .plan:
            addMapView()
//            addParticipationButton() 작업대기#1 서버 버전 업데이트 대기
        case .review:
            addMapView()
        default:
            break
        }
    }
    
    public func configure(with postSummary: PostSummary) {
        setCommonPostInfo(with: postSummary)
        handlePostType(with: postSummary)
    }
    
    private func setCommonPostInfo(with postSummary: PostSummary) {
        thumbnailView.configure(with: .init(meetSummary: postSummary.meet))
        titleLabel.text = postSummary.name
        dateInfoLabel.text = postSummary.dateString
        countInfoLabel.text = postSummary.participantsCountText
        placeInfoLabel.text = postSummary.fullAddress
    }
    
    private func handlePostType(with postSummary: PostSummary) {
        switch postSummary {
        case let planSummary as PlanPostSummary:
            setPlanPostType(with: planSummary)
        case let reviewSummary as ReviewPostSummary:
            setReviewPostType(with: reviewSummary)
        default:
            break
        }
    }
    
    private func setPlanPostType(with planSummary: PlanPostSummary) {
        guard type == .plan else { return }
        setMapView(location: planSummary.location)
//        setParticipationButton(planSummary: planSummary) 작업대기#1 서버 버전 업데이트 대기
    }
    
    private func setReviewPostType(with reviewSummary: ReviewPostSummary) {
        guard type == .review else { return }
        setMapView(location: reviewSummary.location)
    }
}

// MARK: - Setup MapView
extension PostInfoView {
    private func addMapView() {
        mainStackView.addArrangedSubview(mapView)
        mapView.addGestureRecognizer(mapTapGesture)
        mapView.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
    }
    
    private func setMapView(location: Location) {
        mapView.initializeMap(location: location)
    }
}

// MARK: - Setup Participation Button
extension PostInfoView {
    private func addParticipationButton() {
        mainStackView.addArrangedSubview(participationButton)
        participationButton.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }
    
    private func removeParticipationButton() {
        guard mainStackView.arrangedSubviews.contains(participationButton) else { return }
        mainStackView.removeArrangedSubview(participationButton)
        participationButton.removeFromSuperview()
    }
    
    private func setParticipationButton(planSummary: PlanPostSummary) {
        guard !planSummary.isCreator,
              let planDate = planSummary.date,
              planDate > Date() else {
            removeParticipationButton()
            return
        }
        participationButton.title = planSummary.isParticipation
        ? L10n.Meetdetail.planLeave
        : L10n.Meetdetail.planJoin
        participationButton.updateSelectedBackColor(isSelected: planSummary.isParticipation)
        participationButton.updateSelectedTextColor(isSelected: planSummary.isParticipation)
    }
}

extension Reactive where Base: PostInfoView {
    var memberTapped: ControlEvent<Void> {
        return base.membersButton.rx.controlEvent(.touchUpInside)
    }
    
    var mapTapped: Observable<Void> {
        return base.mapTapGesture.rx.event
            .map { _ in }
    }
    
    var participationTapped: ControlEvent<Void> {
        return base.participationButton.rx.tap  
    }
}
