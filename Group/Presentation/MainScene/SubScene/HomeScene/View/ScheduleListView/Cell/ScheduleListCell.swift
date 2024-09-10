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

    private let remainingDateLabel: BaseLabel = {
        let label = BaseLabel(backColor: AppDesign.HomeSchedule.remainingDateLabel,
                                 radius: 4,
                                 padding: .init(top: 0, left: 6, bottom: 0, right: 6),
                                 configure: AppDesign.HomeSchedule.day)
        
        return label
    }()
    
    private let titleLabel: BaseLabel = {
        let label = BaseLabel(configure: AppDesign.HomeSchedule.title)
        return label
    }()
    
    private let placeInfoLabel = IconLabelView(iconSize: 24,
                                               configure: AppDesign.HomeSchedule.placeInfo)
    
    private let dateInfoLabel = IconLabelView(iconSize: 24,
                                              configure: AppDesign.HomeSchedule.dateInfo)
    
    private let detailPlaceInfoLabel = IconLabelView(iconSize: 24,
                                                     configure: AppDesign.HomeSchedule.detailPlaceInfo)
    
    private let emptyView: UIView = {
        let view = UIView()
        view.setContentHuggingPriority(.init(1), for: .vertical)
        return view
    }()
    
    private lazy var infoStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [placeInfoLabel, dateInfoLabel, detailPlaceInfoLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = AppDesign.mainBackColor
        sv.layer.cornerRadius = 8
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 12, left: 12, bottom: 12, right: 12)
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
    
    private let participantCountLabel: BaseLabel = {
        let label = BaseLabel(backColor: AppDesign.HomeSchedule.participantCountLabel,
                                 radius: 4,
                                 padding: .init(top: 0, left: 6, bottom: 0, right: 6),
                                 configure: AppDesign.HomeSchedule.count)
        
        return label
    }()
    
    private lazy var participantStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [participantsImageViews, participantCountLabel])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        sv.spacing = 4
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [remainingDateLabel, titleLabel, infoStackView, participantStackView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .leading
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
        
        infoStackView.snp.makeConstraints { make in
            make.width.equalToSuperview()
        }
        
        remainingDateLabel.snp.makeConstraints { make in
            make.height.equalTo(21)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(28)
        }
        
        placeInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        dateInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(24)
        }
        
        detailPlaceInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        participantCountLabel.snp.makeConstraints { make in
            make.height.equalTo(21)
        }
    }
    
    private func setRadius() {
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 12
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        print("재사용 됩니다.")
    }
}

// MARK: - 데이터 입력
extension ScheduleListCell {
    private func setData(viewModel: ScheduleListItemViewModel?) {
        guard let viewModel = viewModel else { return }
        
        self.remainingDateLabel.text = "D-\(viewModel.remainingDayCount)"
        self.titleLabel.text = viewModel.title
        self.placeInfoLabel.setText(viewModel.place)
        self.detailPlaceInfoLabel.setText(viewModel.detailPlace)
        self.dateInfoLabel.setText(viewModel.releaseDate)
        self.participantCountLabel.text = "\(viewModel.participants.count) 명"
        setParticipantImage(participants: viewModel.participants)
    }
    
    /// 썸네일 뷰 스택뷰에 추가
    private func setParticipantImage(participants: [Participant]) {
        
        participantsImageViews.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let imageViews = getParticipantImage(participants)
        
        imageViews.forEach {
            self.participantsImageViews.addArrangedSubview($0)
        }
        
        setNeedsLayout()
    }
    
    /// 표시할 이미지 제한 및 썸네일 뷰 만들기
    private func getParticipantImage(_ participants: [Participant]) -> [ParticipantImageView] {
        let sliceCount = participants.enumerated().filter { index, _ in
            return index < 10
        }
        
        let imageViews = sliceCount.map { index, value in
            let view = ParticipantImageView(index: index, imagePath: value.imagePath)
            view.layer.zPosition = .init(-index)
            view.snp.makeConstraints { make in
                make.size.equalTo(24)
            }
            return view
        }
        
        return imageViews
    }
    
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct HeaderView_Preview: PreviewProvider {
    static var previews: some View {
        HomeViewController(reactor: ScheduleViewReactor(fetchUseCase: fetchRecentScheduleMock(), logOutAction: LogOutAction(logOut: {
            
        }))).showPreview()
    }
}
#endif

