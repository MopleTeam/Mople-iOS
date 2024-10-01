//
//  TestCell.swift
//  Group
//
//  Created by CatSlave on 9/28/24.
//

import UIKit
import SnapKit

final class TestCell: UITableViewCell {

    private let emptyView: UIView = {
        let view = UIView()
        view.backgroundColor = AppDesign.defaultWihte
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
        self.contentView.addSubview(emptyView)

        emptyView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    private func setRadius() {
        self.emptyView.clipsToBounds = true
        self.emptyView.layer.cornerRadius = 12
    }
}
