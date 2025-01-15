//
//  EventTableViewCell.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

final class CalenadrPalnTableCell: UITableViewCell {
 
    // MARK: - UI Components
    private let thumbnailView: ThumbnailView = {
        let view = ThumbnailView(thumbnailSize: 28,
                                      thumbnailRadius: 6)
        view.setTitleLabel(font: FontStyle.Body2.semiBold,
                           color: ColorStyle.Gray._02)
        view.setSpacing(8)
        view.addArrowImageView()
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title2.bold
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    private let countInfoLabel: IconLabel = {
        let label = IconLabel(icon: .member,
                              iconSize: .init(width: 18, height: 18))
        label.setTitle(font: FontStyle.Body2.medium,
                       color: ColorStyle.Gray._04)
        label.setSpacing(4)
        return label
    }()
                      
    private let weatherView = WeatherView()
    
    private lazy var subStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, countInfoLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, subStackView, weatherView])
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
    
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    private func setLayout() {
        self.backgroundColor = .clear
        self.contentView.addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
        
        thumbnailView.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(25)
        }
        
        countInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(18)
        }
        
        weatherView.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }

    public func configure(viewModel: CalendarPlanTableCellModel) {
        self.titleLabel.text = viewModel.title
        self.countInfoLabel.text = viewModel.participantCountString
        self.thumbnailView.configure(with: ThumbnailViewModel(meetSummary: viewModel.meet))
        self.weatherView.configure(with: .init(weather: viewModel.weather))
    }
}
