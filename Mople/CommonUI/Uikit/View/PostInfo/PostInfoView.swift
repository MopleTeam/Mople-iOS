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
                           color: .text03)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Heading.bold
        label.textColor = .text01
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.regular
        label.textColor = .text02
        label.numberOfLines = 3
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
        label.setContentHuggingPriority(.required, for: .vertical)
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
    
    private lazy var textStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 8
        return sv
    }()
    
    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, textStackView])
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
        sv.spacing = 20
        sv.isUserInteractionEnabled = true
        sv.backgroundColor = .bgPrimary
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        /*UILabel이 여러 줄로 보이려면 먼저 width가 확정돼야 함
        
        UIStackView + 동적 높이 구조에서는 초기 layout 시 width가 0 또는 미확정

        그래서 UIKit이 안전하게 한 줄로만 높이를 계산

        priority, numberOfLines 설정은 있어도 줄바꿈 기준 자체가 없어서 소용없음

        layoutSubviews에서
        preferredMaxLayoutWidth = bounds.width를 지정하자
        → UILabel이 그 width 기준으로 다시 줄바꿈 계산
        → intrinsic height 갱신
        → StackView 높이 정상 반영*/
        descriptionLabel.preferredMaxLayoutWidth = descriptionLabel.bounds.width
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
            make.edges.equalToSuperview().priority(.high)
        }
        
        membersButton.snp.makeConstraints { make in
            make.height.equalTo(24)
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
            $0.setTitle(font: FontStyle.Body1.medium, color: .text02)
            $0.setSpacing(4)
        }
    }
    
    public func configure(with postSummary: PostSummary) {
        thumbnailView.configure(with: .init(meetSummary: postSummary.meet))
        titleLabel.text = postSummary.name
        dateInfoLabel.text = postSummary.dateString
        countInfoLabel.text = postSummary.participantsCountText
        placeInfoLabel.text = postSummary.fullAddress ?? "장소가 없어요"
        if postSummary.description != nil {
            descriptionLabel.text = postSummary.description
        } else {
            descriptionLabel.isHidden = true
        }
        
        self.layoutIfNeeded()
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
