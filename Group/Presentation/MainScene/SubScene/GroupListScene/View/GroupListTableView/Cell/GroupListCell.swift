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
    
    private let thumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let groupTitleLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.Group.title)
        label.setText(text: "그룹 이름")
        return label
    }()
    
    private let memberCountView: IconLabelView = {
        let view = IconLabelView(iconSize: 20,
                                 configure: AppDesign.Group.member)
        view.setText("16 명")
        return view
    }()
    
    private let subButton: UIButton = {
        let btn = UIButton()
        btn.setImage(AppDesign.Group.arrow.itemConfig.image, for: .normal)
        return btn
    }()
    
    private let scheduleView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    private let scheduleLabel: BaseLabel = {
        let label = BaseLabel(backColor: AppDesign.Group.scheduleBack,
                              radius: 10,
                              configure: AppDesign.Group.schedule)
        label.setText(text: "새로운 일정을 추가해보세요.")
        label.textAlignment = .center
        return label
    }()
    
    private lazy var groupInfoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [groupTitleLabel, memberCountView])
        sv.axis = .vertical
        sv.spacing = 4
        sv.distribution = .fill
        sv.alignment = .leading
        sv.setContentHuggingPriority(.init(1), for: .horizontal)
        return sv
    }()
    
    private lazy var topStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, groupInfoStackView, subButton])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    private lazy var mainStackVIew: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [topStackView, scheduleLabel])
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
        loadImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubview(mainStackVIew)
        
        mainStackVIew.snp.makeConstraints { make in
            make.top.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().inset(8)
        }
        
        thumbnailView.snp.makeConstraints { make in
            make.size.equalTo(56)
        }
        
        memberCountView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        scheduleLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }
    
    private func loadImage() {
        let imageUrl = URL(string: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300")
        thumbnailView.kf.setImage(with: imageUrl)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct GroupListViewController_Preview: PreviewProvider {
    static var previews: some View {
        GroupListViewController(title: "모임",
                                reactor: GroupListViewReactor(fetchUseCase: FetchGroupListMock())).showPreview()
    }
}
#endif
