//
//  SearchNavigationView.swift
//  Mople
//
//  Created by CatSlave on 12/22/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class SearchNaviViewController: UIViewController {

    // MARK: - Variables
    public var searchViewBottom: ConstraintItem {
        return searchView.snp.bottom
    }
    
    // MARK: - Observer
    public var searchTapEvent: ControlEvent<Void> {
        return searchView.searchButtonEvent
    }
    
    public var backTapEvent: ControlEvent<Void> {
        return searchView.backButtonEvent
    }
        
    // MARK: - UI Components
    private var searchView = SearchNaviBar()
    
    // MARK: - Indicator
    fileprivate let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = 1
        return indicator
    }()
    
    // MARK: - LifeCycle
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialsetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func initialsetup() {
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        self.view.addSubview(searchView)
        self.view.addSubview(indicator)

        searchView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(56)
        }
                
        indicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

extension Reactive where Base: SearchNaviViewController {
    var isLoading: Binder<Bool> {
        return Binder(self.base) { vc, isLoading in
            vc.indicator.rx.isAnimating.onNext(isLoading)
            vc.view.isUserInteractionEnabled = !isLoading
        }
    }
}
