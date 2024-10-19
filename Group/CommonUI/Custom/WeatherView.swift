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
    let pop: Double?
    
    var temperatureText: String? {
        guard let temperature = temperature else { return nil }
        return "\(temperature)°C"
    }

    var popText: String? {
        guard let pop,
              let popPercent = getPopPercent(pop: pop) else { return nil }
        return "\(popPercent)%"
    }
}

extension WeatherViewModel {
    init?(weather: WeatherInfo?) {
        guard let weather = weather else { return nil }
        self.thumbnailPath = weather.imagePath
        self.temperature = weather.temperature
        self.pop = weather.pop
    }
    
    #warning("round는 정수를 return 정리하기")
    private func getPopPercent(pop: Double) -> Int? {
        switch pop {
        case ..<0.05: return nil
        case 1...: return 100
        default:
            let rounded = (pop * 10).rounded() * 10
            return Int(rounded)
        }
    }
}
#warning("컬러셋 정리하기")
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
    
    private let temperatureLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Weather.temperature)
        label.setContentCompressionResistancePriority(.init(2), for: .horizontal)
        return label
    }()
    
    private let borderLine: UIView = {
        let view = UIView()
        view.backgroundColor = .init(hexCode: "DDDDDD")
        return view
    }()
    
    private let popLabel: IconLabelView = {
        let label = IconLabelView(iconSize: 18,
                                  configure: AppDesign.Schedule.pop)
        label.layer.cornerRadius = 6
        label.backgroundColor = .init(hexCode: "EBF0FF")
        label.setMargin(.init(top: 4, left: 4, bottom: 4, right: 4))
        return label
    }()
    
    #warning("데이터 입력 필요")
    private let cityLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Weather.city)
        label.text = "서울 강남구"
        label.textAlignment = .right
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        label.setContentCompressionResistancePriority(.init(1), for: .horizontal)
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
        let sv = UIStackView(arrangedSubviews: [imageView, weatherStackView, cityLabel])
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
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(32)
        }
        
        borderLine.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(10)
        }
    }
    
    public func configure(with viewModel: WeatherViewModel?) {
        guard let viewModel = viewModel else { return }
        setImage(viewModel.thumbnailPath)
        setTemperatureLabel(viewModel.temperatureText)
        setPopLabel(viewModel.popText)
    }
}

// MARK: - 날씨 정보 업데이트
extension WeatherView {
    
    
    private func setImage(_ path: String?) {
        task = imageView.kfSetimage(path)
    }
    
    private func setTemperatureLabel(_ temperatureText: String?) {
        temperatureLabel.text = temperatureText
    }
    
    private func setPopLabel(_ popText: String?) {
        [borderLine, popLabel].forEach { $0.isHidden = popText == nil }
        popLabel.setText(popText)
    }
}


