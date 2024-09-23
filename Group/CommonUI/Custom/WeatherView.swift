//
//  WeatherView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit
import Kingfisher

// MARK: - ViewModel
struct WeatherViewModel {
    let thumbnailPath: String?
    let temperature: Int?
}

extension WeatherViewModel {
    init(weather: WeatherInfo) {
        self.thumbnailPath = weather.imagePath
        self.temperature = weather.temperature
    }
}

// MARK: - View
final class WeatherView: UIView {
    
    private var task: DownloadTask?
    
    #warning("날씨 기본 이미지 요청하기")
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .white
        return view
    }()
    
    private let temperatureLabel = BaseLabel(configure: AppDesign.Weather.temperature)
    
    #warning("데이터 입력 필요")
    private let cityLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Weather.city)
        label.text = "서울 강남구"
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
    
    deinit {
        task?.cancel()
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
    
    public func configure(with weather: WeatherInfo?) {
        guard let weather = weather else { return }
        setImage(weather.imagePath)
        setTemperatureLabel(temperature: weather.temperature)
    }
}

// MARK: - 날씨 정보 업데이트
extension WeatherView {
    
    
    private func setImage(_ path: String?) {
        guard let path = path else { return }
        let imageUrl = URL(string: path)
        task = self.imageView.kf.setImage(
            with: imageUrl,
            placeholder: AppDesign.Profile.defaultImage,
            options: [.transition(.fade(0.2))]
        )
    }
    
    private func setTemperatureLabel(temperature: Int?) {
        guard let temperature = temperature else { return }
        let stringTemperature = String(temperature) + "°C"
        temperatureLabel.text = stringTemperature
    }
}
