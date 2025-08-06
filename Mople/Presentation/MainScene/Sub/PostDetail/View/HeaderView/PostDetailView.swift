//
//  PostDetailView.swift
//  Mople
//
//  Created by CatSlave on 7/16/25.
//

import UIKit
import RxSwift
import RxCocoa

final class PostDetailView: UIView {
    
    // MARK: - Variables
    private let postType: PostType
    
    // MARK: - UI Components
    fileprivate let postInfoView = PostInfoView()
    
    fileprivate let mapView: MapView = {
        let view = MapView()
        view.layer.cornerRadius = 8
        view.layer.makeLine(width: 1)
        view.backgroundColor = .bgInput
        view.clipsToBounds = true
        view.isUserInteractionEnabled = true
        return view
    }()
    
    private lazy var photoView = PhotoCollectionView()
    
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
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [postInfoView, mapView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = .defaultWhite
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 28, right: 20)
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [subStackView])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private let borderView: UIView = {
        let view = UIView()
        view.backgroundColor = .bgSecondary
        return view
    }()
    
    // MARK: - Gesture
    fileprivate lazy var mapTapGesture = UITapGestureRecognizer()
    
    // MARK: - Life Cycle
    init(postType: PostType) {
        self.postType = postType
        super.init(frame: .zero)
        setupUI()
        setMapGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(mainStackView)
        self.addSubview(borderView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview().priority(.high)
        }
        
        borderView.snp.makeConstraints { make in
            make.top.equalTo(mainStackView.snp.bottom)
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(8)
        }
        
        mapView.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
    }
    
    public func configure(with postSummary: PostSummary) {
        postInfoView.configure(with: postSummary)
        mapView.initializeMap(location: postSummary.location)
        handlePostTypeView(with: postSummary)
    }
    
    private func handlePostTypeView(with postSummary: PostSummary) {
        switch postSummary {
        case let planSummary as PlanPostSummary:
            handleParticipationButton(with: planSummary)
        case let reviewSummary as ReviewPostSummary:
            handlePhotoView(with: reviewSummary)
        default:
            break
        }
    }
    
    // MARK: - Set Gesture
    private func setMapGesture() {
        mapView.addGestureRecognizer(mapTapGesture)
    }
}

// MARK: - Set Participation Button
extension PostDetailView {
    private func handleParticipationButton(with planSummary: PlanPostSummary) {
        guard !planSummary.isCreator else { return }
        
        if let planDate = planSummary.date,
           planDate > Date() {
            addParticipationButton(with: planSummary.isParticipation)
        } else {
            removeParticipationButton()
        }
    }
    
    private func addParticipationButton(with isParticipation: Bool) {
        setParticipation(with: isParticipation)
        guard !subStackView.arrangedSubviews.contains(participationButton) else { return }
        subStackView.addArrangedSubview(participationButton)
        participationButton.snp.makeConstraints { make in
            make.height.equalTo(52)
        }
    }
    
    private func setParticipation(with isParticipation: Bool) {
        participationButton.title = isParticipation
        ? L10n.Meetdetail.planJoined
        : L10n.Meetdetail.planJoin
        participationButton.updateSelectedBackColor(isSelected: isParticipation)
        participationButton.updateSelectedTextColor(isSelected: isParticipation)
    }
    
    private func removeParticipationButton() {
        guard subStackView.arrangedSubviews.contains(participationButton) else { return }
        subStackView.removeArrangedSubview(participationButton)
        participationButton.removeFromSuperview()
    }
}

// MARK: - Set Photo View
extension PostDetailView {
    private func handlePhotoView(with reviewSummary: ReviewPostSummary) {
        let imagePaths = reviewSummary.images.map({ $0.path })
        
        if imagePaths.isEmpty {
            removePhotoView()
        } else {
            addPhotoView(imagePaths: imagePaths)
        }
    }
    
    private func addPhotoView(imagePaths: [String?]) {
        let imageInfos = imagePaths.map { ImageInfo(path: $0) }
        photoView.setImage(images: imageInfos)
        guard !mainStackView.arrangedSubviews.contains(photoView) else { return }
        mainStackView.addArrangedSubview(photoView)
        photoView.snp.makeConstraints { make in
            make.height.equalTo(207)
        }
    }
    
    private func removePhotoView() {
        guard mainStackView.arrangedSubviews.contains(photoView) else { return }
        mainStackView.removeArrangedSubview(photoView)
        photoView.removeFromSuperview()
    }
}

extension Reactive where Base: PostDetailView {
    var memberTapped: ControlEvent<Void> {
        return base.postInfoView.rx.memberTapped
    }
    
    var mapTapped: Observable<Void> {
        return base.mapTapGesture.rx.event
            .map { _ in }
    }
    
    var participationTapped: ControlEvent<Void> {
        return base.participationButton.rx.tap
    }
}
