//
//  ThumbnailView.swift
//  Group
//
//  Created by CatSlave on 9/22/24.
//

import UIKit
import SnapKit

final class ThumbnailTitleView: UIView {
    
    enum ViewType {
        case simple
        case detail
    }
    
    private let thumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()
    
    private let groupTitleLabel = BaseLabel()
    
    private lazy var memberCountView: IconLabelView = {
        let view = IconLabelView(iconSize: 20,
                                 configure: AppDesign.Group.member,
                                 contentSpacing: 4)
        view.setText("5명")
        return view
    }()
    
    private let subButton: UIButton = {
        let btn = UIButton()
        btn.setImage(AppDesign.Group.arrow.itemConfig.image, for: .normal)
        return btn
    }()
    
    private lazy var groupInfoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [groupTitleLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.distribution = .fill
        sv.alignment = .leading
        sv.setContentHuggingPriority(.init(1), for: .horizontal)
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, groupInfoStackView, subButton])
        sv.axis = .horizontal
        sv.spacing = 12
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
    
    
    init(type: ViewType) {
        super.init(frame: .zero)
        setupUI(type)
        loadImage()
        
        #warning("그룹 이름, 멤버 수 설정")
        groupTitleLabel.setText(text: "그룹 이름")
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI(_ type: ViewType) {
        addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        infoConfigure(type)
    }
    
    private func infoConfigure(_ viewCase: ViewType) {
        switch viewCase {
        case .simple:
            setThumbnail(size: 28, radius: 8)
            groupTitleLabel.setType(configure: AppDesign.HomeSchedule.group)
        case .detail:
            setThumbnail(size: 56, radius: 12)
            groupTitleLabel.setType(configure: AppDesign.Group.title)
            makeDetail()
        }
    }
    
    private func setThumbnail(size: CGFloat, radius: CGFloat) {
        thumbnailView.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        thumbnailView.layer.cornerRadius = radius
    }

    private func loadImage() {
        let imageUrl = URL(string: "https://picsum.photos/id/\(Int.random(in: 1...100))/200/300")
        thumbnailView.kf.setImage(with: imageUrl)
    }
}

extension ThumbnailTitleView {
    private func makeDetail() {
        
        groupInfoStackView.addArrangedSubview(memberCountView)
        
        memberCountView.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
    }
}
