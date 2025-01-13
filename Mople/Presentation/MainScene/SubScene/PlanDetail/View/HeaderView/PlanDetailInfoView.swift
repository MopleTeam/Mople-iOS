//
//  PlanDetailHeaderView.swift
//  Mople
//
//  Created by CatSlave on 1/11/25.
//

import UIKit
import SnapKit

final class PlanDetailInfoView: UIView {

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
    
    private let showMembersButton: UIButton = {
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
        return label
    }()

    private let mapView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemTeal
        return view
    }()
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [showMembersButton, dateInfoLabel, placeInfoLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .leading
        sv.spacing = 4
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, titleLabel, subStackView, mapView])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 16
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 20, left: 20, bottom: 28, right: 20)
        return sv
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        setLayout()
        setInfoLabel()
    }
    
    // MARK: - UI Setup
    private func setLayout() {
        self.addSubview(mainStackView)
        self.showMembersButton.addSubview(countInfoLabel)
        self.showMembersButton.addSubview(selectImage)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(31)
        }
        
        [showMembersButton, dateInfoLabel].forEach {
            $0.snp.makeConstraints { make in
                make.height.equalTo(24)
            }
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
    
    public func configure(with plan: PlanDetailViewModel) {
        print(#function, #line, "#6 : \(plan)" )
        thumbnailView.configure(with: .init(meetSummary: plan.meet))
        titleLabel.text = plan.name
        dateInfoLabel.text = plan.dateString
        countInfoLabel.text = plan.participantsCountText
        placeInfoLabel.text = plan.fullAddress
    }
}
