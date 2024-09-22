//
//  EventTableViewCell.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

final class EventTableViewCell: UITableViewCell {

    private var eventView: EventView = .init(type: .simple)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        setupLayout()
        setRadius()
    }
    
    private func setupLayout() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(eventView)

        eventView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setRadius() {
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 12
    }

    public func configure(viewModel: ScheduleListItemViewModel) {
        self.eventView.configure(viewModel)
    }
}
