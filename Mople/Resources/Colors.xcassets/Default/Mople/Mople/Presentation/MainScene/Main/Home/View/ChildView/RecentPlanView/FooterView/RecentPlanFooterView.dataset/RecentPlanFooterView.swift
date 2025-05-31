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
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
        
    // MARK: - UI Components
    private let moreButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: L10n.Home.morePlan,
                     font: FontStyle.Title3.bold,
                     normalColor: .gray03)
        btn.setBgColor(normalColor: .defaultWhite)
        btn.setRadius(12)
        return btn
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.addSubview(moreButton)
        
        moreButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview().inset(20)
        }
    }
    
    // MARK: - Action
    public func setTapAction(on tapObserver: AnyObserver<Void>) {
        moreButton.rx.controlEvent(.touchUpInside)
            .map({ _ in })
            .bind(to: tapObserver)
            .disposed(by: disposeBag)
    }
}


