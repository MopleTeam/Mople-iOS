//
//  GroupListCell.swift
//  Group
//
//  Created by CatSlave on 9/10/24.
//

import UIKit
import SnapKit

final class MeetListTableCell: UITableViewCell {
            
    // MARK: - UI Components
    private let thumbnailView: ThumbnailView = {
        let view = ThumbnailView(thumbnailSize: 56,
                                      thumbnailRadius: 12)
        view.addArrowImageView()
        view.addMemberCountLabel()
        view.setTitleLabel(font: FontStyle.Title3.semiBold,
                           color: .gray01)
        view.setSpacing(12)
        return view
    }()
    
    private let scheduleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = .gray04
        label.backgroundColor = .bgInput
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.textAlignment = .center
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, scheduleLabel])
        sv.axis = .vertical
        sv.spacing = 12
        sv.distribution = .fill
        sv.alignment = .fill
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
    
    // MARK: - UI Setup
    private func setupUI() {
        self.backgroundColor = .clear
        self.contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
        
        scheduleLabel.snp.makeConstraints { make in
            make.height.equalTo(44)
        }
    }

    // MARK: - Configure
    public func configure(with viewModel: ThumbnailViewModel) {
        thumbnailView.configure(with: viewModel)
        formatDateStatusLabel(date: viewModel.lastPlanDate)
    }
    
    private func formatDateStatusLabel(date: Date?) {
        let status = checkScheduleStatus(date: date)
        switch status {
        case .present:
            scheduleLabel.attributedText = NSMutableAttributedString.makeHighlightText(fullText: status.message,
                                                                                       highlightText: L10n.Date.today)
        case let .future(day):
            let dDayTitle = L10n.Date.dday(day)
            scheduleLabel.attributedText = NSMutableAttributedString.makeHighlightText(fullText: status.message,
                                                                                       highlightText: dDayTitle)
        case .past, .none:
            scheduleLabel.text = status.message
        }
    }
}

extension MeetListTableCell {
    
    private enum DateStatus {
        case past(_ day: Int)
        case present
        case future(_ day: Int)
        case none
        
        var message: String {
            switch self {
            case let .past(day):
                return L10n.Meetlist.lastDay(abs(day))
            case .present:
                return L10n.Date.today + " " + L10n.Meetlist.hasPlan
            case let .future(day):
                return L10n.Date.dday(day) + " " + L10n.Meetlist.hasPlan
            case .none:
                return L10n.Meetlist.newPlan
            }
        }
    }
    
    private func checkScheduleStatus(date: Date?) -> DateStatus {
        guard let date else { return .none }
        
        let days = DateManager.numberOfDaysBetween(date)
        switch days {
        case 0: return .present
        case 1...: return .future(days)
        case ...(-1) : return .past(days)
        default: return .none
        }
    }
}

