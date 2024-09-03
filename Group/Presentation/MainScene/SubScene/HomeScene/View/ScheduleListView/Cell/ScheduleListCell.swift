//
//  ScheduleListCell.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import SnapKit

final class ScheduleListCell: UICollectionViewCell {
    static let reuseIdentifier = String(describing: ScheduleListCell.self)

    private let dayLabel: DefaultLabel = {
        let label = DefaultLabel(backColor: AppDesign.HomeSchedule.dayBackColor,
                                  radius: 4,
                                  itemConfigure: AppDesign.HomeSchedule.day)
        label.backgroundColor = .systemRed
        return label
    }()
    
    private let titleLabel: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.title)
        label.backgroundColor = .systemOrange
        return label
    }()
    
    #warning("이미지랑 합친 label 만들기")
    private let placeInfo: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.info)
        label.backgroundColor = .systemYellow
        return label
    }()
    
    private let dayInfo: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.info)
        label.backgroundColor = .systemGreen
        return label
    }()
    
    private let detailPlaceInfo: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.info)
        label.backgroundColor = .systemBlue
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [placeInfo, dayInfo, detailPlaceInfo])
        sv.backgroundColor = .purple
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        return sv
    }()
    
    #warning("테스트 뷰 -> 스택뷰로 전환")
    private let testImageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .systemMint
        view.image = UIImage(named: "participant")
        return view
    }()
    
    private let participantCount: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.count)
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()
    
    private lazy var participantStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [testImageView, participantCount])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 4
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [dayLabel, titleLabel, infoStackView, participantStackView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setRadius()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func setupUI() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
    }
    
    private func setRadius() {
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 12
    }
}

