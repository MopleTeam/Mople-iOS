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
    
    private let label: BaseButton = {
        let label = BaseButton(backColor: AppDesign.defaultWihte,
                               radius: 12,
                               configure: AppDesign.Schedule.moreSchedule)
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
        setAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.addSubview(label)
        
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setAction() {
        label.rx.controlEvent(.touchUpInside)
            .subscribe(onNext: { _ in
                print("터치 됨")
            })
            .disposed(by: disposeBag)
    }
}
