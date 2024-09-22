//
//  EventView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

final class EventView: UIView {
    
    enum ViewType {
        case simple
        case detail
    }
    
    private lazy var thumbnailView: ThumbnailTitleView = {
        let view = ThumbnailTitleView(type: .simple)
        return view
    }()
    
    private let titleLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.HomeSchedule.event)
        return label
    }()
    
    private let countInfoLabel: IconLabelView = {
        let label = IconLabelView(iconSize: 18,
                                  configure: AppDesign.HomeSchedule.count,
                                  contentSpacing: 4)
        return label
    }()
    
    private lazy var dateInfoLabel: IconLabelView = {
        let label = IconLabelView(iconSize: 18,
                                  configure: AppDesign.HomeSchedule.date,
                                  contentSpacing: 4)
        return label
    }()
    
    private lazy var placeInfoLabel: IconLabelView = {
        let label = IconLabelView(iconSize: 18,
                                  configure: AppDesign.HomeSchedule.place,
                                  contentSpacing: 4)
        return label
    }()

    private let weatherInfo = WeatherView()
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init(type: ViewType) {
        super.init(frame: .zero)
        
        setupUI()
        setType(type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .white
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        
        thumbnailView.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        
        countInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        
        weatherInfo.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    public func configure(_ viewModel: ScheduleListItemViewModel) {
        self.titleLabel.text = viewModel.title
        self.countInfoLabel.setText("\(viewModel.participantCount)")
        self.dateInfoLabel.setText(viewModel.date)
        self.placeInfoLabel.setText(viewModel.place)
        self.thumbnailView.setData(viewModel.group)
    }
}

// MARK: - 타입 별 UI 구성
extension EventView {
    
    private func setType(_ type: ViewType) {
        switch type {
        case .simple:
            setSimpleType()
        case .detail:
            setDetailType()
        }
    }
    
    // 홈 화면 타입
    private func setDetailType() {
        [countInfoLabel, dateInfoLabel, placeInfoLabel].forEach {
            subStackView.addArrangedSubview($0)
        }

        dateInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        
        placeInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(34)
        }
            
        [titleLabel, subStackView, weatherInfo].forEach {
            mainStackView.addArrangedSubview($0)
        }
    }
    
    // 캘린더 타입
    private func setSimpleType() {
        [titleLabel, countInfoLabel].forEach {
            subStackView.addArrangedSubview($0)
        }
        
        [subStackView, weatherInfo].forEach {
            mainStackView.addArrangedSubview($0)
        }
    }
}
