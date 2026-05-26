//
//  NoticeComposeViewController.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SnapKit

// Phase 1 placeholder. 공지 리스트 화면 안의 작성 버튼에서만 진입. 모임장만 노출.
final class NoticeComposeViewController: TitleNaviViewController {

    private let meetId: Int

    init(meetId: Int) {
        self.meetId = meetId
        super.init(screenName: .notice_compose,
                   title: "공지 작성")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .bgPrimary
        setupPlaceholder()
    }

    private func setupPlaceholder() {
        let label = UILabel()
        label.text = "공지 작성 화면 (구현 예정)\nmeetId: \(meetId)"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .text03
        label.font = FontStyle.Body1.medium

        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
    }
}
