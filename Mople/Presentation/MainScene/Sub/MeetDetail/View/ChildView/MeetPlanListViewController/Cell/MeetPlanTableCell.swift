//
//  FuturePlanTableCell.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

final class MeetPlanTableCell: UITableViewCell {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - Closure
    var completeTapped: (() -> Void)?
        
    // MARK: - UI Components
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.semiBold
        label.textColor = .gray04
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()

    private let arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .listArrow
        return imageView
    }()

    private let titleLabel: IconLabel = {
        let label = IconLabel(icon: .circlePan,
                              iconSize: .init(width: 20, height: 22))
        label.setTitle(font: FontStyle.Title3.semiBold,
                       color: .gray01)
        label.setSpacing(4)
        return label
    }()

    private let countInfoLabel: IconLabel = {
        let label = IconLabel(icon: .member,
                              iconSize: .init(width: 20, height: 20))
        label.setTitle(font: FontStyle.Body2.medium,
                       color: .gray04)
        label.setSpacing(4)
        label.setTitleTopPadding(3)
        return label
    }()

    private let weatherView = WeatherView()

    private lazy var participationButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(font: FontStyle.Body1.semiBold,
                     normalColor: .defaultWhite,
                     selectedColor: .gray03)
        btn.setBgColor(normalColor: .appPrimary,
                       selectedColor: .appTertiary)
        btn.setRadius(8)
        return btn
    }()
    
    private lazy var endPlanLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Meetdetail.planEnd
        label.font = FontStyle.Body1.medium
        label.textColor = .gray05
        label.textAlignment = .center
        return label
    }()

    private lazy var headerStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [dateLabel, arrowImage])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .center
        return sv
    }()
     
    private lazy var bodyStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, countInfoLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()

    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStackView, bodyStackView, weatherView])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = .defaultWhite
        sv.layer.cornerRadius = 12
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 16, left: 16, bottom: 16, right: 16)
        return sv
    }()

    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        removePlanEndLabel()
        removeParticipationButton()
        disposeBag = DisposeBag()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubview(mainStackView)

        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
    
        headerStackView.snp.makeConstraints { make in
            make.height.equalTo(24).priority(.high)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.height.equalTo(22).priority(.high)
        }
        
        countInfoLabel.snp.makeConstraints { make in
            make.height.equalTo(20).priority(.high)
        }

        weatherView.snp.makeConstraints { make in
            make.height.equalTo(56).priority(.high)
        }
    }

    // MARK: - Configure
    public func configure(viewModel: MeetPlanViewModel) {
        self.dateLabel.text = viewModel.dateString
        self.titleLabel.text = viewModel.title
        self.countInfoLabel.text = viewModel.participantCountString
        self.weatherView.configure(with: .init(weather: viewModel.weather))
        self.handleViewType(isCreator: viewModel.isCreator,
                             isParticipant: viewModel.isParticipant,
                             planDate: viewModel.date)
    }
    
    private func handleViewType(isCreator: Bool,
                                 isParticipant: Bool?,
                                 planDate: Date?) {
        handleTitlePostIcon(isCreator: isCreator)
        handleParticipation(isCreator: isCreator,
                            planDate: planDate,
                            isParticipation: isParticipant)
    }
    
    private func handleTitlePostIcon(isCreator: Bool) {
        self.titleLabel.hideIcon(isHide: !isCreator)
    }
    
    private func handleParticipation(isCreator: Bool,
                                     planDate: Date?,
                                     isParticipation: Bool?) {
        guard let planDate,
              let isParticipation else { return }
        
        if shouldParticipation(planDate: planDate) {


            addParticipationButton(isCreator: isCreator,
                                   isParticipation: isParticipation)
        } else {
            
            addPlanEndLabel()
        }
    }
    
    private func shouldParticipation(planDate: Date) -> Bool {
        return planDate > Date()
    }
}

// MARK: - Participation Button Setup
extension MeetPlanTableCell {
    private func addParticipationButton(isCreator: Bool,
                                        isParticipation: Bool) {
        guard !isCreator else { return }
        mainStackView.addArrangedSubview(participationButton)
        
        participationButton.snp.updateConstraints { make in
            make.height.equalTo(52).priority(.high)
        }
        setParticipation(isParticipation)
    }
    
    private func removeParticipationButton() {
        guard mainStackView.arrangedSubviews.contains(participationButton) else { return }
        mainStackView.removeArrangedSubview(participationButton)
        participationButton.removeFromSuperview()
    }
    
    private func setParticipation(_ isParticipant: Bool) {
        setParitipationAction()
        participationButton.title = isParticipant
        ? L10n.Meetdetail.planLeave
        : L10n.Meetdetail.planJoin
        participationButton.updateSelectedBackColor(isSelected: isParticipant)
        participationButton.updateSelectedTextColor(isSelected: isParticipant)
    }
    
    private func setParitipationAction() {
        participationButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { tableCell, _ in
                print(#function, #line, "Path : # 참여 버튼 클릭 ")
                tableCell.completeTapped?()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - PlanEnd Label Setup
extension MeetPlanTableCell {
    private func addPlanEndLabel() {
        mainStackView.addArrangedSubview(endPlanLabel)
        endPlanLabel.snp.makeConstraints { make in
            make.height.equalTo(36)
        }
    }
    
    private func removePlanEndLabel() {
        guard mainStackView.arrangedSubviews.contains(endPlanLabel) else { return }
        mainStackView.removeArrangedSubview(endPlanLabel)
        endPlanLabel.removeFromSuperview()
    }
}



