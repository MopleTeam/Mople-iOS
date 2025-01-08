//
//  ScheduleListCell.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import SnapKit

final class HomePlanCollectionCell: UICollectionViewCell {

    private let thumbnailView: ThumbnailTitleView = {
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
        return label
    }()
    
    private let dateInfoLabel: IconLabel = {
        let label = IconLabel(icon: .date, iconSize: 18)
        return label
    }()
    
    private let placeInfoLabel: IconLabel = {
        let label = IconLabel(icon: .place, iconSize: 18)
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
        sv.backgroundColor = ColorStyle.Default.white
        sv.layer.cornerRadius = 12
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return sv
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        setLayout()
        setInfoLabel()
    }
    
    private func setLayout() {
        self.contentView.addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
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
    
    private func setInfoLabel() {
        [countInfoLabel, dateInfoLabel, placeInfoLabel].forEach {
            $0.setTitle(font: FontStyle.Body2.medium, color: ColorStyle.Gray._04)
            $0.setSpacing(4)
        }
    }

    public func configure(with viewModel: HomePlanCollectionCellViewModel) {
        self.titleLabel.text = viewModel.title
        self.countInfoLabel.text = viewModel.participantCountString
        self.dateInfoLabel.text = viewModel.dateString
        self.placeInfoLabel.text = viewModel.address
        self.thumbnailView.configure(with: ThumbnailViewModel(meetSummary: viewModel.meet))
        self.weatherView.configure(with: .init(weather: viewModel.weather))
    }
}


