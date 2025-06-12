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
    private var isForceUpdate: Bool = false
    
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
        bind()
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
        viewModel.checkAppVersion()
    }
    
    private func bind() {
        self.viewModel.errObservable
            .asDriver(onErrorJustReturn: nil)
            .compactMap({ $0 })
            .drive(with: self, onNext: { vc, err in
                vc.handleLaunchError(err)
            })
            .disposed(by: disposeBag)
        
        NotificationManager.shared.addEnterForeGroundObservable()
            .filter({ [weak self] _ in
                return self?.isForceUpdate == true
            })
            .observe(on: MainScheduler.instance)
            .bind(with: self, onNext: { vc, _ in
                vc.showForceUpdateAlert()
            })
            .disposed(by: disposeBag)
    }
    
    private func handleLaunchError(_ err: LaunchError) {
        switch err {
        case .forceUpdateRequired:
            isForceUpdate = true
            showForceUpdateAlert()
        }
    }
    
    private func showForceUpdateAlert() {
        alertManager.showDefaultAlert(title: L10n.AppForceUpdate.title,
                                      subTitle: L10n.AppForceUpdate.message,
                                      defaultAction: .init(completion: { [weak self] in
            self?.openMopleAppStor()
        }))
    }
    
    private func openMopleAppStor() {
        guard let appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/id6738402542") else { return }
        UIApplication.shared.open(appStoreURL)
    }
}
