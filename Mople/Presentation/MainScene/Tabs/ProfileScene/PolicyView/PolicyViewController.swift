//
//  PolicyViewController.swift
//  Group
//
//  Created by CatSlave on 10/24/24.
//

import UIKit
import RxSwift

final class PolicyViewController: DefaultViewController {
    
    var disposeBag = DisposeBag()
    
    init() {
        print(#function, #line, "LifeCycle Test PolicyView Created" )
        super.init(title: "개인정보 처리방침")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test PolicyView Deinit" )
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
