//
//  FuturePlanTableCell.swift
//  Mople
//
//  Created by CatSlave on 1/6/25.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import SnapKit

final class FuturePlanTableCell: UITableViewCell {
    
    public var disposeBag = DisposeBag()
        
    fileprivate var planId: Int?

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = ColorStyle.Gray._04
        label.setContentHuggingPriority(.init(1), for: .horizontal)
        return label
    }()

    private let arrowImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = .listArrow
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title.bold
        label.textColor = ColorStyle.Gray._01
        return label
    }()

    private let countInfoLabel: IconLabel = {
        let label = IconLabel(icon: .member, iconSize: 20)
        label.setTitle(font: FontStyle.Body2.medium, color: ColorStyle.Gray._04)
        label.setSpacing(4)
        return label
    }()

    private let weatherView = WeatherView()

    fileprivate let completdButton: BaseButton = {
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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    #warning("재사용 시 init이 호출되지 않고 prepareForReuse만 호출된다")
    override func prepareForReuse() {
        super.prepareForReuse()
        addCompletionButton()
        disposeBag = DisposeBag()
    }
    
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

    public func configure(viewModel: FuturePlanTableCellModel, userID: Int?) {
        self.planId = viewModel.id
        self.dateLabel.text = viewModel.dateString
        self.titleLabel.text = viewModel.title
        self.countInfoLabel.text = viewModel.participantCountString
        self.weatherView.configure(with: .init(weather: viewModel.weather))
        self.handleCompletdButton(userID: userID,
                                  postUserID: viewModel.postUserID,
                                  isParticipant: viewModel.isParticipant,
                                  planDate: viewModel.date)
    }
    
    private func handleCompletdButton(userID: Int?,
                                      postUserID: Int?,
                                      isParticipant: Bool?,
                                      planDate: Date?) {
        guard let userID,
              let postUserID,
              let isParticipant,
              let planDate else { return }
                
        guard isButtonEnabledForDate(planDate) else { return }
        guard shouldShowAuthorButtons(userID: userID, postUserID: postUserID) else { return }
        isAlreadyParticipated(isParticipant)
    }
}

extension FuturePlanTableCell {
    private func isButtonEnabledForDate(_ date: Date) -> Bool {
        guard date < Date() else { return true }
        completdButton.isEnabled = false
        completdButton.setTitle(text: "해당 약속은 마감되었어요",
                                font: FontStyle.Body1.medium,
                                normalColor: ColorStyle.Gray._05)
        return false
    }
    
    private func shouldShowAuthorButtons(userID: Int, postUserID: Int) -> Bool {
        guard userID == postUserID else { return true }
        removeCompletionButton()
        return false
    }
    
    private func isAlreadyParticipated(_ isParticipant: Bool) {
        completdButton.setTitle(font: FontStyle.Body1.semiBold,
                                normalColor: ColorStyle.Default.white,
                                selectedColor: ColorStyle.Gray._03)
        completdButton.title = isParticipant ? "약속 불참" : "약속 참여하기"
        completdButton.updateSelectedBackColor(isSelected: isParticipant)
        completdButton.updateSelectedTextColor(isSelected: isParticipant)
    }
    
    private func addCompletionButton() {
        if !mainStackView.arrangedSubviews.contains(completdButton) {
            mainStackView.addArrangedSubview(completdButton)
        }
        completdButton.isEnabled = true
    }
    
    private func removeCompletionButton() {
        if mainStackView.arrangedSubviews.contains(completdButton) {
            mainStackView.removeArrangedSubview(completdButton)
            completdButton.removeFromSuperview()
        }
    }
}

extension Reactive where Base: FuturePlanTableCell {
    var completed: Observable<Int> {
                
        return base.completdButton.rx.controlEvent(.touchUpInside)
            .compactMap { base.planId }
            .debug("joining")
    }
}

