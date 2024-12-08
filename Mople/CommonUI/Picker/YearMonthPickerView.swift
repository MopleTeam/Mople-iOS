//
//  DatePickerView.swift
//  Mople
//
//  Created by CatSlave on 12/6/24.
//

import UIKit
import RxSwift
import RxRelay

final class YearMonthPickerView: DefaultPickerView {
        
    // MARK: - Variables
    
    private let todayComponents = DateManager.todayComponents
    public lazy var selectedDate = todayComponents
    
    private lazy var years: [Int] = {
        let currentYear = todayComponents.year ?? 2024
        let startYear = currentYear - 10
        let endYear = currentYear + 10
        return Array(startYear...endYear)
    }()
    
    private let months: [Int] = Array(1...12)
        
    // MARK: - LifeCycle
    override init(title: String?) {
        print(#function, #line, "LifeCycle Test DatePickerView Created" )
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
extension YearMonthPickerView: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: years.count
        case 1: months.count
        default: 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int,
                    reusing view: UIView?) -> UIView {
        
        let label = self.dequeuePickerLabel(reusing: view)
        
        switch component {
        case 0: label.text = "\(years[row]) 년"
        case 1: label.text = "\(months[row]) 월"
        default: break
        }
        
        return label
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        switch component {
        case 0: selectedDate.year = years[row]
        case 1: selectedDate.month = months[row]
        default: break
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 35
    }
}

// MARK: - Input Date
extension YearMonthPickerView {
    public func defaultSelectedDate(on dateComponents: DateComponents? = nil) {
        if let dateComponents {
            self.selectDate(dateComponents)
        } else {
            self.selectDate(todayComponents)
        }
    }
    
    private func selectDate(_ dateComponents: DateComponents) {
        guard let year = dateComponents.year,
              let month = dateComponents.month else { return }
        
        let yearIndex = self.years.firstIndex(of: year) ?? 2025
        let monthIndex = self.months.firstIndex(of: month) ?? 1
        
        self.selectRow(row: yearIndex, inComponent: 0, animated: false)
        self.selectRow(row: monthIndex, inComponent: 1, animated: false)
    }
}

