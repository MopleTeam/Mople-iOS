//
//  PolicyViewController.swift
//  Group
//
//  Created by CatSlave on 10/24/24.
//

import UIKit
import WebKit
import RxSwift

final class PolicyViewController: TitleNaviViewController {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
        
    // MARK: - UI Components
    private let webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let view = WKWebView(frame: .zero, configuration: webConfiguration)
        view.scrollView.contentInsetAdjustmentBehavior = .never
        return view
    }()
    
    init(screenName: ScreenName,
         title: String?) {
        super.init(screenName: screenName,
                   title: title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        webViewConfigure()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setLayout()
        setNaviItem()
    }
    
    private func setLayout() {
        self.view.addSubview(webView)
        
        webView.snp.makeConstraints { make in
            make.top.equalTo(titleViewBottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func setNaviItem() {
        self.setBarItem(type: .left)
    }

    // MARK: - Binding
    func bind() {
        naviBar.leftItemEvent
            .asDriver(onErrorJustReturn: ())
            .drive(with: self, onNext: { vc, _ in
                vc.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - WebView Configure
    func webViewConfigure() {
        let policyURLString = AppConfiguration.policyURL
        guard let policyURL = URL(string: policyURLString) else { return }
        webView.load(URLRequest(url: policyURL))
    }
    
}
