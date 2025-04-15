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
        label.textColor = ColorStyle.Gray._04
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
                       color: ColorStyle.Gray._01)
        label.setSpacing(4)
        return label
    }()

    private let countInfoLabel: IconLabel = {
        let label = IconLabel(icon: .member,
                              iconSize: .init(width: 20, height: 20))
        label.setTitle(font: FontStyle.Body2.medium,
                       color: ColorStyle.Gray._04)
        label.setSpacing(4)
        label.setTitleTopPadding(3)
        return label
    }()

    private let weatherView = WeatherView()

    private let completdButton: BaseButton = {
        let btn = BaseButton()
        btn.setBgColor(normalColor: ColorStyle.App.primary,
                       selectedColor: ColorStyle.App.tertiary,
                       disabledColor: .clear)
        btn.setRadius(8)
        btn.clipsToBounds = true
        return btn
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
        let sv = UIStackView(arrangedSubviews: [headerStackView, bodyStackView, weatherView, completdButton])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        sv.backgroundColor = ColorStyle.Default.white
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
        addCompletionButton()
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
        
        completdButton.snp.makeConstraints { make in
            make.height.equalTo(52).priority(.high)
        }
    }
    
    private func buttonSizeDown() {
        completdButton.snp.updateConstraints { make in
            make.height.equalTo(36).priority(.high)
        }
    }
    
    private func buttonSizeUp() {
        completdButton.snp.updateConstraints { make in
            make.height.equalTo(52).priority(.high)
        }
    }
    
    // MARK: - Action
    private func setAction() {
        completdButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { tableCell, _ in
                tableCell.completeTapped?()
            })
            .disposed(by: disposeBag)
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
        handleCompletdButton(isCreator: isCreator,
                             isParticipant: isParticipant,
                             planDate: planDate)
    }
    
    private func handleTitlePostIcon(isCreator: Bool) {
        self.titleLabel.hideIcon(isHide: !isCreator)
    }
}

// MARK: - Participation Button Setup
extension MeetPlanTableCell {
    private func handleCompletdButton(isCreator: Bool,
                                      isParticipant: Bool?,
                                      planDate: Date?) {
        guard let isParticipant,
              let planDate,
              isButtonEnabledForDate(planDate) else { return }
        updateButtonVisibility(isCreator: isCreator,
                               isParticipation: isParticipant)
    }
    
    private func isButtonEnabledForDate(_ date: Date) -> Bool {
        guard date < Date() else { return true }
        completdButton.isEnabled = false
        completdButton.setTitle(text: "해당 약속은 마감되었어요",
                                font: FontStyle.Body1.medium,
                                normalColor: ColorStyle.Gray._05)
        buttonSizeDown()
        return false
    }
    
    private func updateButtonVisibility(isCreator: Bool,
                                        isParticipation: Bool) {
        if isCreator {
            removeCompletionButton()
        } else {
            isAlreadyParticipated(isParticipation)
        }
    }
    
    private func isAlreadyParticipated(_ isParticipant: Bool) {
        setAction()
        completdButton.setTitle(font: FontStyle.Body1.semiBold,
                                normalColor: ColorStyle.Default.white,
                                selectedColor: ColorStyle.Gray._03)
        completdButton.title = isParticipant ? "약속 불참" : "약속 참여하기"
        completdButton.updateSelectedBackColor(isSelected: isParticipant)
        completdButton.updateSelectedTextColor(isSelected: isParticipant)
    }
    
    private func removeCompletionButton() {
        guard mainStackView.arrangedSubviews.contains(completdButton) else { return }
        mainStackView.removeArrangedSubview(completdButton)
        completdButton.removeFromSuperview()
    }
    
    private func addCompletionButton() {
        if mainStackView.arrangedSubviews.contains(completdButton) == false {
            mainStackView.addArrangedSubview(completdButton)
        }
        buttonSizeUp()
        completdButton.isEnabled = true
    }
}



