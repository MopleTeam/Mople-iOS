//
//  MeetDetailNaviTitleView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

// 모임 상세 네비바 중앙 — 모임 썸네일(28×28) + 이름(Medium 14) 가로 스택.
// TitleNaviBar.setCustomTitleView로 중앙에 얹는다.
// 썸네일 탭 시 사진 크게보기로 이동 (rx.imageTap). 이름은 별도 동작 확장 여지를 위해 탭 대상에서 제외.
final class MeetDetailNaviTitleView: UIView {

    // 썸네일 탭 제스처 (사진 크게보기 진입용)
    fileprivate let imageTapGesture = UITapGestureRecognizer()

    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.appStroke.cgColor
        iv.isUserInteractionEnabled = true   // 탭 받도록 활성화
        return iv
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.medium
        label.textColor = .text01
        label.textAlignment = .left
        return label
    }()

    private lazy var stackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailImageView, nameLabel])
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 8
        return sv
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        thumbnailImageView.snp.makeConstraints { make in
            make.size.equalTo(28)
        }
        thumbnailImageView.addGestureRecognizer(imageTapGesture)
    }

    func configure(name: String?, imagePath: String?) {
        nameLabel.text = name
        if let path = imagePath, let url = URL(string: path) {
            thumbnailImageView.kf.setImage(with: url, placeholder: UIImage(named: "defaultMeet"))
        } else {
            thumbnailImageView.image = UIImage(named: "defaultMeet")
        }
    }
}

// MARK: - Reactive
extension Reactive where Base: MeetDetailNaviTitleView {
    // 썸네일 탭 → 사진 크게보기 진입에 사용
    var imageTap: Observable<Void> {
        return base.imageTapGesture.rx.event.map { _ in }
    }
}
