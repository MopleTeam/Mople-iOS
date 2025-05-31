//
//  DefaultPickerView.swift
//  Mople
//
//  Created by CatSlave on 11/21/24.
//

import UIKit
import RxSwift
import RxCocoa

final class DefaultPickerView: UIView {

    // MARK: - UI Components
    private let pickerView = UIPickerView()

    private(set) lazy var modalView: DefaultModalView = {
        let view = DefaultModalView(contentView: pickerView)
        view.setCompletedBUtton()
        return view
    }()
    
    // MARK: - LifeCycle
    init(title: String?) {
        super.init(frame: .zero)
        setLayout()
        setTitle(title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setLayout() {
        self.addSubview(modalView)
        
        modalView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setTitle(_ title: String?) {
        modalView.setTitle(title)
    }
}

// MARK: - Select
extension DefaultPickerView {
    public func selectRow(row: Int, inComponent: Int, animated: Bool) {
        guard pickerView.numberOfComponents - 1 >= inComponent,
              pickerView.numberOfRows(inComponent: inComponent) - 1 >= row else { return }
        
        pickerView.selectRow(row, inComponent: inComponent, animated: animated)
    }
}

// MARK: - Reload
extension DefaultPickerView {
    public func reloadComponent(_ component: Int) {
        guard self.pickerView.numberOfComponents > component else { return }
        self.pickerView.reloadComponent(component)
    }
}

// MARK: - Delegate
extension DefaultPickerView {
    public func setDelegate(delegate: UIPickerViewDataSource & UIPickerViewDelegate ) {
        pickerView.delegate = delegate
    }
}

// MARK: - Dequeue Reusable
extension DefaultPickerView {
    public func dequeuePickerLabel(reusing view: UIView?) -> UILabel {
        return (view as? UILabel) ?? {
            let newLabel = UILabel()
            newLabel.textAlignment = .center
            newLabel.textColor = .black
            newLabel.font = FontStyle.Title2.semiBold
            return newLabel
        }()
    }
}
