//
//  FooterView.swift
//  Group
//
//  Created by CatSlave on 9/15/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ScheduleListReuseFooterView: UICollectionReusableView {
    
    var disposeBag = DisposeBag()
        
    private let moreButton: BaseButton = {
        let label = BaseButton()
        label.setTitle(text: TextStyle.Home.moreBtnTitle,
                       font: FontStyle.Title3.semiBold,
                       color: ColorStyle.Gray._01)
        label.setBgColor(ColorStyle.Default.white)
        label.setImage(image: .plus,
                       imagePlacement: .top)
        label.layer.cornerRadius = 12
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(moreButton)
        
        moreButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    public func setTapAction(on tapObserver: AnyObserver<Void>) {
        moreButton.rx.controlEvent(.touchUpInside)
            .map({ _ in })
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
    }
}
