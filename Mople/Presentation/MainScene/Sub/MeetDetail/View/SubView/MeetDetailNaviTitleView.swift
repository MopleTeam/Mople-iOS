//
//  MeetDetailNaviTitleView.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SnapKit
import Kingfisher

// 모임 상세 네비바 중앙 — 모임 썸네일(28×28) + 이름(Medium 14) 가로 스택.
// 기존 TitleNaviBar의 titleLabel을 가리는 형태로 addSubview한다.
final class MeetDetailNaviTitleView: UIView {

    private let thumbnailImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 6
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.appStroke.cgColor
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
