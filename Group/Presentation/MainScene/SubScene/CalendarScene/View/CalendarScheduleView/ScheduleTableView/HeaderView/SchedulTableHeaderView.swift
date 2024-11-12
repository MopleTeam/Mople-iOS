//
//  SchedulTableHeaderView.swift
//  Group
//
//  Created by CatSlave on 9/23/24.
//

import UIKit
import SnapKit

final class SchedulTableHeaderView: UITableViewHeaderFooterView {

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = ColorStyle.Gray._05
        label.textAlignment = .center
        return label
    }()
    
    
    // MARK: - LifeCycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(20)
        }
    }
    
    public func setTitle(title: String?, tag: Int) {
        titleLabel.text = title ?? "날짜 정보 없음"
        self.tag = tag
    }
}
