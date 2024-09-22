//
//  WeatherView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

final class WeatherView: UIView {
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()
    
    private let temperatureLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Weather.temperature)
        label.setText(text: "32°C")
        return label
    }()
    
    private let cityLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Weather.city)
        label.setText(text: "서울 강남구")
        return label
    }()
    
    private lazy var weatherInfo: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageView, temperatureLabel, cityLabel])
        sv.layer.cornerRadius = 10
        sv.backgroundColor = AppDesign.Weather.backColor
        sv.spacing = 12
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
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
        addSubview(weatherInfo)
        
        weatherInfo.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
    }
}
