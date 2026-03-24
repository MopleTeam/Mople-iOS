//
//  EmptyDataViewController.swift
//  Mople
//
//  Created by CatSlave on 12/8/25.
//

import UIKit
import RxSwift
import RxCocoa

final class EmptyDataViewController: UIViewController {
    
    private lazy var warningImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = .warning
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray01
        label.font = FontStyle.Title2.semiBold
        label.textAlignment = .center
        label.text = "연결 실패"
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray02
        label.font = FontStyle.Body1.regular
        label.textAlignment = .center
        label.numberOfLines = 2
        label.text = "서버와의 연결이 불안정합니다.\n잠시 후 다시 시도해주세요."
        return label
    }()
    
    fileprivate let refreshButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: "새로고침",
                     font: FontStyle.Body1.semiBold,
                     normalColor: .defaultWhite)
        btn.setBgColor(normalColor: .appPrimary)
        btn.setRadius(6)
        return btn
    }()
    
    
    private lazy var mainSV: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [warningImageView,
                                                titleLabel,
                                                subTitleLabel,
                                                refreshButton])
        sv.axis = .vertical
        sv.spacing = 24
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setLayout()
    }
        
    private func setLayout() {
        self.view.backgroundColor = .defaultWhite
        self.view.addSubview(mainSV)
        
        mainSV.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension Reactive where Base: EmptyDataViewController {
    var refresh: Observable<Void> {
        return base.refreshButton.rx.tap
            .asObservable()
    }
}
