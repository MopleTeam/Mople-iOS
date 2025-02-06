//
//  ReviewEditHeaderView.swift
//  Mople
//
//  Created by CatSlave on 2/6/25.
//

import UIKit
import RxSwift
import RxCocoa

final class PhotoCollectionHeaderView: UICollectionReusableView {
    
    var addButtonTapped: (() -> Void)?
    
    var disposeBag = DisposeBag()
    
    private let addButton: UIButton = {
        let btn = UIButton()
        btn.setImage(.largePlus, for: .normal)
        btn.backgroundColor = ColorStyle.BG.primary
        btn.layer.makeLine(width: 1)
        btn.layer.cornerRadius = 8
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        initalSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initalSetup() {
        setupUI()
        bind()
    }
    
    private func setupUI() {
        self.addSubview(addButton)
        
        addButton.snp.makeConstraints { make in
            make.verticalEdges.equalToSuperview().inset(20)
            make.leading.equalToSuperview().inset(20)
            make.trailing.equalToSuperview()
        }
    }
    
    private func bind() {
        addButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.addButtonTapped?()
            })
            .disposed(by: disposeBag)
    }
}
