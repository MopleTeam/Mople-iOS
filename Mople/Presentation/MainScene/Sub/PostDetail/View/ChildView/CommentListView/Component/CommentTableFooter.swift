//
//  CommentTableFooter.swift
//  Mople
//
//  Created by CatSlave on 8/5/25.
//

import UIKit
import Domain
import RxSwift
import RxCocoa
import SnapKit

final class CommentListTableFooterView: UIView {
    
    private let defaultFrame: CGRect
    
    // MARK: - UI Compoentns
    private let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - LifeCycle
    override init(frame: CGRect) {
        self.defaultFrame = frame
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.addSubview(indicator)
        indicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    public func setLoading(_ isLoad: Bool) {
        if isLoad {
            indicator.startAnimating()
            self.frame = defaultFrame
        } else {
            indicator.stopAnimating()
            self.frame = .init(origin: .zero, size: .init(width: 0, height: 0.1))
        }
    }
}
