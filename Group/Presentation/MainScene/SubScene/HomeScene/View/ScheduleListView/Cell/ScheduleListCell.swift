//
//  ScheduleListCell.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import SnapKit

final class ScheduleListCell: UICollectionViewCell {
    
    var viewModel: ScheduleListItemViewModel? {
        didSet {
            self.setData(viewModel: viewModel)
        }
    }

    private let remainingDateLabel: DefaultLabel = {
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
    private let placeInfoLabel: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.info)
        label.backgroundColor = .systemYellow
        return label
    }()
    
    private let dateInfoLabel: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.info)
        label.backgroundColor = .systemGreen
        return label
    }()
    
    private let detailPlaceInfoLabel: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.info)
        label.setContentHuggingPriority(.init(1), for: .vertical)
        label.backgroundColor = .systemBlue
        return label
    }()
    
    private lazy var infoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [placeInfoLabel, dateInfoLabel, detailPlaceInfoLabel])
        sv.backgroundColor = .purple
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
        sv.setContentHuggingPriority(.init(1), for: .vertical)
        return sv
    }()
    
    private let participantsImageViews: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.distribution = .fillEqually
        sv.alignment = .fill
        sv.spacing = -14
        return sv
    }()
    
    private let participantCountLabel: DefaultLabel = {
        let label = DefaultLabel(itemConfigure: AppDesign.HomeSchedule.count)
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()
    
    private lazy var participantStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [participantsImageViews, participantCountLabel])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 4
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [remainingDateLabel, titleLabel, infoStackView, participantStackView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("cell 생성")
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
        
//        participantStackView.snp.makeConstraints { make in
//            make.height.equalTo(28)
//        }
    }
    
    private func setRadius() {
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 12
    }
    
    private func setData(viewModel: ScheduleListItemViewModel?) {
        guard let viewModel = viewModel else { return }
        
        self.remainingDateLabel.text = "D-\(viewModel.remainingDayCount)"
        self.titleLabel.text = viewModel.title
        self.placeInfoLabel.text = viewModel.place
        self.detailPlaceInfoLabel.text = viewModel.detailPlace
        self.dateInfoLabel.text = viewModel.releaseDate
        self.participantCountLabel.text = "\(viewModel.participants.count) 명"
        setParticipantImage(participants: viewModel.participants)
    }
    
    private func setParticipantImage(participants: [Participant]) {
        
        participantsImageViews.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let imageViews = participants.enumerated().map { index, value in
            let view = ParticipantImageView(index: index, imagePath: value.imagePath)
            view.layer.zPosition = .init(-index)
            view.snp.makeConstraints { make in
                make.size.equalTo(28)
            }
            return view
        }
        
        imageViews.forEach {
            self.participantsImageViews.addArrangedSubview($0)
        }
        
        setNeedsLayout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        print("재사용 됩니다.")
    }
}

//#if DEBUG
//import SwiftUI
//
//@available(iOS 13, *)
//struct HeaderView_Preview: PreviewProvider {
//    static var previews: some View {
//        HomeViewController(reactor: ScheduleViewReactor(fetchUseCase: fetchRecentScheduleMock())).showPreview()
//    }
//}
//#endif
