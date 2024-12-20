//
//  ScheduleListCell.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import SnapKit

final class HomePlanCollectionCell: UICollectionViewCell {

    private let scheduleView = ScheduleView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(scheduleView)

        scheduleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setRadius() {
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 12
    }

    public func configure(with viewModel: PlanViewModel) {
        self.scheduleView.configure(viewModel)
    }
}


