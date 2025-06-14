//
//  MeetThumbnailView.swift
//  Mople
//
//  Created by CatSlave on 6/6/25.
//

import UIKit

final class MeetDetailThumbnail: ThumbnailView {
    
    private let arrowImageView: UIImageView = {
        let view = UIImageView(image: .listArrow)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    public let inviteButton = UIButton()
    
    override init(thumbnailSize: CGFloat,
                  thumbnailRadius: CGFloat) {
        super.init(thumbnailSize: thumbnailSize,
                   thumbnailRadius: thumbnailRadius)
        setLayout()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        inviteButton.addSubview(memberCountLabel)
        groupInfoStackView.addArrangedSubview(inviteButton)

        inviteButton.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        
        memberCountLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func setMemberCount(_ countText: String?) {
        guard let countText else { return }
        memberCountLabel.text = countText + " · " + L10n.Meetdetail.invite
        memberCountLabel.addContent(with: arrowImageView, size: .init(width: 20, height: 20))
        memberCountLabel.setSpacing(0)
        memberCountLabel.isUserInteractionEnabled = false
    }
}
