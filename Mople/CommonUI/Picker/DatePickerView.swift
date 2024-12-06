//
//  DatePickerView.swift
//  Mople
//
//  Created by CatSlave on 12/6/24.
//

import UIKit
import RxSwift
import RxRelay

enum DatePickerViewType: Int {
    case yearMonth = 2
    case fullDate = 3
}

final class DatePickerView: DefaultPickerView {
        
    // MARK: - Variables
    private let viewType: DatePickerViewType
    
    private let today = DateManager.todayComponents
    public lazy var selectedDate = today
    
    private lazy var years: [Int] = {
        let currentYear = today.year ?? 2024
        let startYear = currentYear - 10
        let endYear = currentYear + 10
        return Array(startYear...endYear)
    }()
    
    private let months: [Int] = Array(1...12)
    
    private let dates = DateManager.getDaysInCurrentMonth()
    
    // MARK: - LifeCycle
    init(title: String?,
         type: DatePickerViewType) {
        print(#function, #line, "LifeCycle Test DatePickerView Created" )
        self.viewType = type
        super.init(title: title)
        initialSetup()
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test DatePickerView Created" )
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initialSetup() {
        self.setDelegate(delegate: self)
    }
}

// MARK: - Delegate
extension DatePickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return viewType.rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: years.count
        case 1: months.count
        case 2: dates.count
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = self.dequeuePickerLabel(reusing: view)
        
        switch component {
        case 0: label.text = "\(years[row]) 년"
        case 1: label.text = "\(months[row]) 월"
        case 2: label.text = "\(dates[row]) 일"
        default: break
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0: selectedDate.year = years[row]
        case 1: selectedDate.month = months[row]
        case 2: selectedDate.day = dates[row]
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Input Date
extension DatePickerView {
    public func defaultSelectedDate(on dateComponents: DateComponents? = nil) {
        if let dateComponents {
            self.selectDate(dateComponents)
        } else {
            self.selectDate(today)
        }
    }
    
    private func selectDate(_ dateComponents: DateComponents) {
        guard let year = dateComponents.year,
              let month = dateComponents.month,
              let day = dateComponents.day else { return }
        
        let yearIndex = self.years.firstIndex(of: year) ?? 2025
        let monthIndex = self.months.firstIndex(of: month) ?? 1
        let dateIndex = self.dates.firstIndex(of: day) ?? 1
        
        self.selectRow(row: yearIndex, inComponent: 0, animated: false)
        self.selectRow(row: monthIndex, inComponent: 1, animated: false)
        self.selectRow(row: dateIndex, inComponent: 2, animated: false)
    }
}

