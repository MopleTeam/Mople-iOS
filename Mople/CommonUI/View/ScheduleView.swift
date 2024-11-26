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
    let title: String?
    let date: Date?
    let group: CommonGroup?
    let address: String?
    let detailAddress: String?
    let participantCount: Int?
    let weather: WeatherInfo?
    
    var participantCountString: String? {
        guard let participantCount = participantCount else { return nil }
        
        return "\(participantCount)명 참여"
    }
    
    var dateString: String? {
        guard let date else { return nil }
        
        return DateManager.toString(date: date, format: .full)
    }
}

extension ScheduleViewModel {
    init(schedule: SimpleSchedule) {
        self.title = schedule.title
        self.date = schedule.date
        self.group = schedule.group
        self.address = schedule.address
        self.detailAddress = schedule.detailAddress
        self.participantCount = schedule.participantsCount
        self.weather = schedule.weatherInfo
    }
}

// MARK: - View
final class ScheduleView: UIView {
    
    private lazy var thumbnailView: ThumbnailTitleView = {
        let view = ThumbnailTitleView(type: .simple)
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
    
    public func configure(_ viewModel: ScheduleViewModel) {
        
        self.titleLabel.text = viewModel.title
        
        self.countInfoLabel.text = viewModel.participantCountString
        self.dateInfoLabel.text = viewModel.dateString
        self.placeInfoLabel.text = viewModel.detailAddress
        
        self.thumbnailView.configure(with: ThumbnailViewModel(group: viewModel.group))
        self.weatherView.configure(with: .init(weather: viewModel.weather))
    }
}

