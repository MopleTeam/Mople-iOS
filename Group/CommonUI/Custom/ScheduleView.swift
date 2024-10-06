//
//  EventView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

// MARK: - ViewModel
struct ScheduleViewModel {
    let group: Group?
    let title: String?
    let date: String?
    let place: String?
    let participantCount: Int?
    let weather: WeatherInfo?
    
    var participantCountString: String? {
        guard let participantCount = participantCount else { return nil }
        
        return "\(participantCount)명 참여"
    }
}

extension ScheduleViewModel {
    init(schedule: Schedule) {
        self.group = schedule.group
        self.title = schedule.title
        self.place = schedule.place
        self.date = schedule.stringDate
        self.participantCount = schedule.participants?.count
        self.weather = schedule.weather
    }
}

// MARK: - View
final class ScheduleView: UIView {
    
    private lazy var thumbnailView: ThumbnailTitleView = {
        let view = ThumbnailTitleView(type: .simple)
        return view
    }()
    
    private let titleLabel = BaseLabel(configure: AppDesign.Schedule.title)
    
    private let countInfoLabel = IconLabelView(iconSize: 18,
                                                configure: AppDesign.Schedule.count,
                                                contentSpacing: 4)
    
    private lazy var dateInfoLabel: IconLabelView = {
        let label = IconLabelView(iconSize: 18,
                                  configure: AppDesign.Schedule.date,
                                  contentSpacing: 4)
        return label
    }()
    
    private lazy var placeInfoLabel: IconLabelView = {
        let label = IconLabelView(iconSize: 18,
                                  configure: AppDesign.Schedule.place,
                                  contentSpacing: 4)
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
    
    public func configure(_ viewModel: ScheduleViewModel) {
        
        self.titleLabel.text = viewModel.title
        
        self.countInfoLabel.setText(viewModel.participantCountString)
        self.dateInfoLabel.setText(viewModel.date)
        self.placeInfoLabel.setText(viewModel.place)
        
        self.thumbnailView.configure(with: ThumbnailViewModel(group: viewModel.group))
        self.weatherView.configure(with: .init(weather: viewModel.weather))
    }
}

