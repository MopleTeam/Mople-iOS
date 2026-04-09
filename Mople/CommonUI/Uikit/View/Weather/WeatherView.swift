//
//  WeatherView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Kingfisher

final class WeatherView: UIView {
    
    private var task: DownloadTask?
    
    private var tapped: (() -> Void)?
    
    private var disposeBag = DisposeBag()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.image = .weather
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.backgroundColor = .bgPrimary
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
        label.textColor = .text01
        return label
    }()
    
    private let borderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .gray07
        return view
    }()
    
    private let popLabel: IconLabel = {
        let label = IconLabel(icon: .pop,
                              iconSize: .init(width: 18, height: 18))
        label.layer.cornerRadius = 6
        label.backgroundColor = .appBlueGray
        label.setTitle(font: FontStyle.Body2.bold,
                       color: .defaultBlue)
        label.setMargin(.init(top: 4, left: 4, bottom: 4, right: 4))
        return label
    }()
    
    private let cityLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = .text03
        label.textAlignment = .right
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let nonWeatherLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = .text03
        label.textAlignment = .center
        label.text = "아직 날씨를 알 수 없어요"
        label.isUserInteractionEnabled = true
        return label
    }()
    
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
        sv.backgroundColor = .bgInput
        sv.spacing = 12
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        return sv
    }()
    
    // MARK: - Gesture
    private let gesture = UITapGestureRecognizer()
    
    init() {
        super.init(frame: .zero)
        setupUI()
        addGesture()
        bind()
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
    
    public func configure(with viewModel: WeatherViewModel?,
                          isCreator: Bool,
                          isValidPlan: Bool? = nil,
                          weatherTap: (() -> Void)? = nil) {
        self.tapped = weatherTap
        self.isUserInteractionEnabled = viewModel == nil && isCreator
        
        if let viewModel = viewModel {
            setWeatherView(hasWeather: viewModel.hasWeatherInfo)
            setWeatherInfoView(with: viewModel)
            return
        } else {
            setWeatherInfoView(with: .getEmptyWeather())
        }
        
        setWeatherView(hasWeather: false)
        
        if isValidPlan == false {
            setWeatherInfoLabel("날씨 정보가 없습니다.")
        } else {
            let infoText = isCreator ? "장소를 추가해주세요" : "아직 장소를 정하지 않았어요"
            setWeatherInfoLabel(infoText)
        }
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
    
    private func addGesture() {
        self.addGestureRecognizer(gesture)
    }

    private func bind() {
        gesture.rx.event
            .subscribe(with: self, onNext: { view, _ in
                view.tapped?()
            })
            .disposed(by: disposeBag)
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
    
    private func setWeatherInfoLabel(_ text: String) {
        nonWeatherLabel.text = text
    }
    
    private func setPopLabel(_ popText: String?) {
        [borderLine, popLabel].forEach { $0.isHidden = popText == nil }
        popLabel.text = popText
    }
    
    private func setCityLabel(_ cityName: String?) {
        cityLabel.text = cityName
    }
}



