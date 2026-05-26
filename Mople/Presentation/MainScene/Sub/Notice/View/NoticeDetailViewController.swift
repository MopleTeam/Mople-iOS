//
//  NoticeDetailViewController.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SnapKit

// Phase 1 placeholder. 미리보기 카드에서 진입.
final class NoticeDetailViewController: TitleNaviViewController {

    private let noticeId: Int

    init(noticeId: Int) {
        self.noticeId = noticeId
        super.init(screenName: .notice_detail,
                   title: "공지 상세")
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
        label.text = "공지 상세 화면 (구현 예정)\nnoticeId: \(noticeId)"
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
