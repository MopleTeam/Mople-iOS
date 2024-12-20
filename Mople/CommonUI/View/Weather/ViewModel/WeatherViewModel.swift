//
//  WeatherViewModel.swift
//  Mople
//
//  Created by CatSlave on 12/16/24.
//

import Foundation

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
    init?(weather: Weather?) {
        guard let weather = weather else { return nil }
        self.thumbnailPath = weather.imagePath
        self.temperature = weather.faceTemperature
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





