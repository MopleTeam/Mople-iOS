//
//  EmptyView.swift
//  Group
//
//  Created by CatSlave on 9/9/24.
//

import UIKit
import SnapKit

class BaseEmptyView: UIView {
    
    private var configure: UIConstructive
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = configure.itemConfig.image
        return view
    }()
    
    private lazy var label: BaseLabel = {
        let label = BaseLabel(configure: configure)
        return label
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [imageView, label])
        sv.axis = .vertical
        sv.spacing = 20
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    
    init(configure: UIConstructive) {
        self.configure = configure
        
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        imageView.snp.makeConstraints { make in
            make.size.equalTo(80)
        }
    }
}


//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//struct BaseEmptyView_Preview: PreviewProvider{
//    static var previews: some View {
//        UIViewPreview {
//            return BaseEmptyView(configure: AppDesign.)
//        }
//    }
//}
//#endif
