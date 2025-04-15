//
//  MapSelectView.swift
//  Mople
//
//  Created by CatSlave on 4/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class MapSelectViewController: UIViewController {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let naverMapButton = CustomModalView.makeModalButton(title: "네이버지도",
                                                              image: .naverMap)
    
    private let kakaoMapButton = CustomModalView.makeModalButton(title: "카카오맵",
                                                              image: .kakaoMap)
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [naverMapButton, kakaoMapButton])
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var modalView = CustomModalView(contentView: buttonStackView)
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setModalGesture()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.addSubview(modalView)
        
        modalView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Action
    private func setAction() {
        
    }
    
    // MARK: - Gesture
    private func setModalGesture() {
        modalView.dismissObservable
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.dismiss(animated: false)
            })
            .disposed(by: disposeBag)
    }
}


