//
//  SearchResultTableHeaderView.swift
//  Mople
//
//  Created by CatSlave on 12/27/24.
//

import UIKit
import SnapKit

final class SearchTableHeaderView: UITableViewHeaderFooterView {

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "최근 검색"
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._01
        label.textAlignment = .left
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.text = "3개"
        label.font = FontStyle.Title3.semiBold
        label.textColor = ColorStyle.Gray._04
        label.textAlignment = .right
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
        
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(countLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview().inset(20)
        }
        
        countLabel.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    public func setCount(_ count: Int) {
        self.countLabel.text = "\(count)개"
    }
}
