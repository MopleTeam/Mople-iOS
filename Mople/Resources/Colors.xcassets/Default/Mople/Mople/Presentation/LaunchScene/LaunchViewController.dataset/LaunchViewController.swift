//
//  LaunchViewController.swift
//  Mople
//
//  Created by CatSlave on 2/11/25.
//

import UIKit
import RxSwift
import FirebaseAnalytics


final class LaunchViewController: DefaultViewController {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    
    // MARK: - ViewModel
    private let viewModel: LaunchViewModel
    
    // MARK: - UI Components
    private let logoImage: UIImageView = {
        let view = UIImageView()
        view.image = .launchScreenIcon
        view.contentMode = .center
        return view
    }()
    
    // MARK: - LifeCycle
    init(screenName: ScreenName,
         viewModel: LaunchViewModel) {
        self.viewModel = viewModel
        super.init(screenName: screenName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkAccount()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = .defaultWhite
        self.view.addSubview(logoImage)
        
        logoImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func checkAccount() {
        viewModel.checkEntry()
    }
}
