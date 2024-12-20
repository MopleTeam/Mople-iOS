//
//  EventView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

final class ScheduleView: UIView { // PlanView
    
    private lazy var thumbnailView: ThumbnailTitleView = {
        let view = ThumbnailTitleView(type: .basic)
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title.bold
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    private let countInfoLabel: IconLabel = {
        let label = IconLabel(icon: .member, iconSize: 18)
        label.setTitle(font: FontStyle.Body2.medium, color: ColorStyle.Gray._04)
        label.setSpacing(4)
        return label
    }()
    
    private lazy var dateInfoLabel: IconLabel = {
        let label = IconLabel(icon: .date, iconSize: 18)
        label.setTitle(font: FontStyle.Body2.medium, color: ColorStyle.Gray._04)
        label.setSpacing(4)
        return label
    }()
    
    private lazy var placeInfoLabel: IconLabel = {
        let label = IconLabel(icon: .place, iconSize: 18)
        label.setTitle(font: FontStyle.Body2.medium, color: ColorStyle.Gray._04)
        label.setSpacing(4)
        return label
    }()

    private let weatherView = WeatherView()
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [countInfoLabel, dateInfoLabel, placeInfoLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, titleLabel, subStackView, weatherView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    init() {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = ColorStyle.Default.white
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
        
        dateInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        
        placeInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(34)
        }
        
        weatherView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    public func configure(_ viewModel: PlanViewModel) {
        
        self.titleLabel.text = viewModel.title
        
        self.countInfoLabel.text = viewModel.participantCountString
        self.dateInfoLabel.text = viewModel.dateString
        self.placeInfoLabel.text = viewModel.address
        self.thumbnailView.configure(with: ThumbnailViewModel(meet: viewModel.meet))
        self.weatherView.configure(with: .init(weather: viewModel.weather))
    }
}

