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

final class PostInfoView: UIView {

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
        return label
    }()
    
    private let placeInfoLabel: IconLabel = {
        let label = IconLabel(icon: .place,
                              iconSize: .init(width: 24, height: 24))
        return label
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
        sv.backgroundColor = .defaultWhite
        return sv
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        setLayout()
        setInfoLabel()
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
    
    public func configure(with postSummary: PostSummary) {
        thumbnailView.configure(with: .init(meetSummary: postSummary.meet))
        titleLabel.text = postSummary.name
        dateInfoLabel.text = postSummary.dateString
        countInfoLabel.text = postSummary.participantsCountText
        placeInfoLabel.text = postSummary.fullAddress
    }
    
    public func setMargin(inset: UIEdgeInsets) {
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.layoutMargins = inset
    }
}


extension Reactive where Base: PostInfoView {
    var memberTapped: ControlEvent<Void> {
        return base.membersButton.rx.controlEvent(.touchUpInside)
    }
}
