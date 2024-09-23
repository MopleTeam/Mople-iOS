//
//  EventTableViewCell.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

final class ScheduleTableViewCell: UITableViewCell {

    private let scheduleView: SimpleScheduleView = {
        let view = SimpleScheduleView()
        return view
    }()
    
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
        self.contentView.addSubview(scheduleView)

        scheduleView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func setRadius() {
        self.scheduleView.clipsToBounds = true
        self.scheduleView.layer.cornerRadius = 12
    }

    public func configure(viewModel: ScheduleViewModel) {
        self.scheduleView.configure(viewModel)
    }
}
