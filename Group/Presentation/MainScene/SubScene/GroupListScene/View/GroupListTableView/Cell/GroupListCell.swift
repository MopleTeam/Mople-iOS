//
//  GroupListCell.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import UIKit
import SnapKit
import Kingfisher

final class GroupListCell: UITableViewCell {
    
    private let thumbnailView = ThumbnailTitleView(type: .detail)
    
    #warning("데이터 입력 필요")
    private let scheduleLabel: BaseLabel = {
        let label = BaseLabel(backColor: AppDesign.Group.scheduleBack,
                              radius: 10,
                              configure: AppDesign.Group.schedule)
        label.text = "새로운 일정을 추가해보세요."
        label.textAlignment = .center
        return label
    }()
    
    private lazy var mainStackVIew: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, scheduleLabel])
        sv.axis = .vertical
        sv.spacing = 12
        sv.distribution = .fill
        sv.alignment = .fill
        sv.backgroundColor = AppDesign.defaultWihte
        sv.layer.cornerRadius = 12
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return sv
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubview(mainStackVIew)
        
        mainStackVIew.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
        
        scheduleLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    public func configure(with viewModel: ThumbnailViewModel?) {
        guard let viewModel = viewModel else { return }
        thumbnailView.configure(with: viewModel)
    }
}
