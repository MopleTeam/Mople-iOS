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
    
    private lazy var leftButtonObserver = addLeftButton()

    init() {
        super.init(title: "개인정보 처리방침")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }

    // MARK: - Binding
    func bind() {
        leftButtonObserver
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
}
