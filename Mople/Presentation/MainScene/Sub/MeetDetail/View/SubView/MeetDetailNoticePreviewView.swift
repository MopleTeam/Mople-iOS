//
//  MeetDetailNoticePreviewView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

// MeetDetail 본문 상단의 공지 미리보기 카드 (80px / r12 / bg white / shadow).
// pinnedNotice가 nil일 때는 숨김 처리(외부에서 isHidden 토글).
final class MeetDetailNoticePreviewView: UIView {

    // MARK: - Public
    var tapEvent: ControlEvent<Void> { tapControl.rx.controlEvent(.touchUpInside) }

    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .bgPrimary
        view.layer.cornerRadius = 12
        view.layer.makeShadow(opactity: 0.02, radius: 12, offset: .init(width: 0, height: 0))
        return view
    }()

    // 헤더(아이콘 + 라벨)
    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        iv.image = .megaphone
        iv.tintColor = .defaultRed1
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.semiBold
        label.textColor = .text03
        label.text = "공지알림"
        return label
    }()

    private lazy var headerStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [iconImageView, headerLabel])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 4
        return sv
    }()

    private let contentLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = .text02
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private lazy var verticalStack: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [headerStack, contentLabel])
        sv.axis = .vertical
        sv.alignment = .leading
        sv.spacing = 4
        return sv
    }()

    // 카드 전체를 덮는 투명 버튼 — 탭 이벤트 단순화
    private let tapControl: UIControl = {
        let c = UIControl()
        c.backgroundColor = .clear
        return c
    }()

    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(containerView)
        containerView.addSubview(verticalStack)
        containerView.addSubview(tapControl)

        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        verticalStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
        }
        tapControl.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    // MARK: - Configure
    func configure(content: String?) {
        contentLabel.text = content
    }
}
