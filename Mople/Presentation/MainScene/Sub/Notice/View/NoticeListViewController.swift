//
//  NoticeListViewController.swift
//  Mople
//
//  Created by CatSlave on 5/26/26.
//

import UIKit
import SnapKit

// Phase 1 placeholder. 본 화면은 후속 PR에서 구현.
// 확성기 버튼에서 진입. 작성 진입점은 isCreator일 때만 노출 예정.
final class NoticeListViewController: TitleNaviViewController {

    private let meetId: Int
    private let isCreator: Bool

    init(meetId: Int, isCreator: Bool) {
        self.meetId = meetId
        self.isCreator = isCreator
        super.init(screenName: .notice_list,
                   title: "공지사항")
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
        label.text = "공지 리스트 화면 (구현 예정)\nmeetId: \(meetId)\nisCreator: \(isCreator)"
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
