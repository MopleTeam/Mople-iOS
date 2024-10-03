//
//  TestCell.swift
//  Group
//
//  Created by CatSlave on 9/28/24.
//

import UIKit
import SnapKit

struct EmptySchedule: DateProviding {
    var date: Date
}

final class EmptyScheduleCell: UITableViewCell {

    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = AppDesign.defaultWihte
        return view
    }()
    
    private let label = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setLayout()
        setRadius()
    }
    
    private func setLayout() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.contentView.addSubview(emptyView)
        emptyView.addSubview(label)

        emptyView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func setRadius() {
        self.emptyView.clipsToBounds = true
        self.emptyView.layer.cornerRadius = 12
    }
    
    public func setLabel(on date: Date) {
        let today = Date().getComponents()
        let inputDay = date.getComponents()
        
        if inputDay < today  {
            label.text = "과거 입니다."
        } else {
            label.text = "현재 또는 미래입니다."
        }
    }
}
