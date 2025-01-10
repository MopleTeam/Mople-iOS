//
//  WeatherViewModel.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

struct WeatherViewModel {
    let iconType: String?
    let temperature: Double?
    let pop: Double?
    let address: String?
    
    var hasWeatherInfo: Bool {
        return temperature != nil
    }
    
    var roundedTemperature: Int? {
        guard let temperature else { return nil }
        let rounded = temperature.rounded()
        return Int(rounded)
    }
    
    var temperatureText: String? {
        guard let roundedTemperature else { return nil }
        return "\(roundedTemperature)°C"
    }

    var popText: String? {
        guard let pop,
              let popPercent = getPopPercent(pop: pop) else { return nil }
        return "\(popPercent)%"
    }
    
    var iconImagePath: String? {
        guard let iconType else { return nil }
        return "https://openweathermap.org/img/wn/\(iconType)@2x.png"
    }
}

extension WeatherViewModel {
    init?(weather: Weather?) {
        guard let weather = weather else { return nil }
        self.iconType = weather.imagePath
        self.temperature = weather.temperature
        self.pop = weather.pop
        self.address = weather.address
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





