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

final class RecentPlanFooterView: UICollectionReusableView {
    
    var disposeBag = DisposeBag()
        
    private let moreButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Home.moreBtnTitle,
                       font: FontStyle.Title3.semiBold,
                       normalColor: ColorStyle.Gray._01)
        btn.setBgColor(normalColor: ColorStyle.Default.white)
        btn.setImage(image: .plus,
                       imagePlacement: .top)
        btn.setRadius(12)
        return btn
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
