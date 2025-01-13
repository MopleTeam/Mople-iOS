//
//  FutruePlanTableHeaderView.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import UIKit
import SnapKit

final class MeetPlanTableHeaderView: UITableViewHeaderFooterView {

    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = ColorStyle.Gray._04
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()
    
    private let countLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = ColorStyle.Gray._04
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 0, left: 20, bottom: 16, right: 20)
        return sv
    }()
    
    // MARK: - LifeCycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        prepareContentViewLayout()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(mainStackView)
        mainStackView.snp.makeConstraints { make in
            make.center.size.equalToSuperview()
        }
    }
    
    public func setLabel(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = "\(count)개"
    }
    
    /// 뷰컨트롤러에 의해서 테이블뷰가 생성될 땐 문제가 발생하지 않으나 페이지 컨트롤러에 의해서 생성 시 헤더뷰의 높이가 0이라는 경고가 표시됨
    /// 해당 경고를 막기위해 초기부터 높이를 지정해줌
    private func prepareContentViewLayout() {
        self.contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 36)
    }
}
