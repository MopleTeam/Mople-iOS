//
//  WeatherView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit
import Kingfisher


#warning("컬러셋 정리하기")
final class WeatherView: UIView {
    
    private var task: DownloadTask?
    
#warning("날씨 기본 이미지 요청하기")
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = .weather
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = ColorStyle.Default.white
        return view
    }()
    
    private let imageContainer: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(999), for: .horizontal)
        view.setContentCompressionResistancePriority(.init(999), for: .horizontal)
        return view
    }()
    
    private let temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.semiBold
        label.textColor = ColorStyle.Gray._01
        return label
    }()
    
    private let borderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hexCode: "DDDDDD")
        return view
    }()
    
    private let popLabel: IconLabel = {
        let label = IconLabel(icon: .pop,
                              iconSize: .init(width: 18, height: 18))
        label.layer.cornerRadius = 6
        label.backgroundColor = ColorStyle.Default.blueGray
        label.setTitle(font: FontStyle.Body2.bold,
                       color: ColorStyle.Default.blue)
        label.setMargin(.init(top: 4, left: 4, bottom: 4, right: 4))
        return label
    }()
    
    #warning("데이터 입력 필요")
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = ColorStyle.Gray._04
        label.textAlignment = .right
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let nonWeatherLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = ColorStyle.Gray._04
        label.textAlignment = .center
        label.text = "아직 날씨를 알 수 없어요"
        return label
    }()
    
    private let spaceView = UIView()
    
    private lazy var weatherStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [temperatureLabel, borderLine, popLabel])
        sv.axis = .horizontal
        sv.spacing = 15.5
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageContainer, weatherStackView, cityLabel])
        sv.distribution = .fill
        sv.alignment = .center
        sv.layer.cornerRadius = 10
        sv.backgroundColor = ColorStyle.BG.input
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
        addSubview(mainStackView)
        mainStackView.addSubview(nonWeatherLabel)
        imageContainer.addSubview(imageView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.trailing.equalToSuperview().priority(.low)
            make.size.equalTo(32)
        }
        
        borderLine.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(10)
        }
        
        nonWeatherLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(44)
        }
    }
    
    public func configure(with viewModel: WeatherViewModel?) {
        guard let viewModel = viewModel else { return }
        setWeatherView(hasWeather: viewModel.hasWeatherInfo)
        setWeatherInfoView(with: viewModel)
    }
    
    private func setWeatherView(hasWeather: Bool) {
        weatherStackView.isHidden = !hasWeather
        cityLabel.isHidden = !hasWeather
        nonWeatherLabel.isHidden = hasWeather
    }
    
    private func setWeatherInfoView(with viewModel: WeatherViewModel) {
        setImage(viewModel.iconImagePath)
        setTemperatureLabel(viewModel.temperatureText)
        setPopLabel(viewModel.popText)
        setCityLabel(viewModel.address)
    }
}

// MARK: - 날씨 정보 업데이트
extension WeatherView {
    private func setImage(_ path: String?) {
        task = imageView.kfSetimage(path, defaultImageType: .weather)
    }
    
    private func setTemperatureLabel(_ temperatureText: String?) {
        temperatureLabel.text = temperatureText
    }
    
    private func setPopLabel(_ popText: String?) {
        [borderLine, popLabel].forEach { $0.isHidden = popText == nil }
        popLabel.text = popText
    }
    
    private func setCityLabel(_ cityName: String?) {
        cityLabel.text = cityName
    }
}



