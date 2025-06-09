//
//  MemberTableHeader.swift
//  Mople
//
//  Created by CatSlave on 6/6/25.
//

import UIKit
import RxSwift
import SnapKit
import RxCocoa

final class MemberTableHeader: UITableViewHeaderFooterView {
    
    fileprivate let inviteButton = UIButton()
    
    private let inviteView: MemberListView = {
        let view = MemberListView()
        view.isUserInteractionEnabled = false
        return view
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
        setInviteUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(inviteButton)
        self.inviteButton.addSubview(inviteView)
        
        inviteButton.snp.makeConstraints { make in
            make.top.equalToSuperview().priority(.high)
            make.horizontalEdges.equalToSuperview().inset(20).priority(.high)
            make.bottom.equalToSuperview().inset(4).priority(.high)
        }
        
        inviteView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setInviteUI() {
        inviteView.memberInfoView.profileView.image = .invitePlus
        inviteView.memberInfoView.profileView.contentMode = .center
        inviteView.memberInfoView.backgroundColor = .bgPrimary
        inviteView.nameLabel.text = L10n.Meetdetail.invite
        inviteView.nameLabel.textColor = .appPrimary
    }
}

extension Reactive where Base: MemberTableHeader {
    var tapped: ControlEvent<Void> {
        return base.inviteButton.rx.tap
    }
}
