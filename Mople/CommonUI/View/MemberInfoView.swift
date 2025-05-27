//
//  MemberInfoView.swift
//  Mople
//
//  Created by CatSlave on 2/4/25.
//

import UIKit
import RxSwift
import SnapKit

final class MemberInfoView: UIView {
    
    public let profileView: UserImageView = {
        let view = UserImageView()
        view.setLayer()
        return view
    }()
    
    private let positionTypeView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.addSubview(profileView)
        self.addSubview(positionTypeView)
        
        profileView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        positionTypeView.snp.makeConstraints { make in
            make.size.equalTo(16)
            make.bottom.trailing.equalToSuperview()
        }
    }
    
    public func setConfigure(imagePath: String?, position: MemberPositionType?) {
        profileView.setImage(imagePath)
        positionTypeView.image = position?.image
    }
    
    public func cancleImageLoad() {
        profileView.cancleImageLoad()
    }
}
