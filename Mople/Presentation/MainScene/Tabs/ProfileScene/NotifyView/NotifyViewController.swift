//
//  NotifyViewController.swift
//  Group
//
//  Created by CatSlave on 10/24/24.
//

import UIKit
import RxSwift

final class NotifyViewController: DefaultViewController {
    
    var disposeBag = DisposeBag()
    

    init() {
        print(#function, #line, "LifeCycle Test NotifyView Created" )
        super.init(title: "알림 관리 뷰")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test NotifyView Deinit" )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        setNaviItem()
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left, image: .arrowBack)
    }

    // MARK: - Binding
    func bind() {
        leftItemEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
