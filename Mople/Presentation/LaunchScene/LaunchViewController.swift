//
//  LaunchViewController.swift
//  Mople
//
//  Created by CatSlave on 2/11/25.
//

import UIKit
import RxSwift

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
    init(viewModel: LaunchViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        checkAccount()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.backgroundColor = ColorStyle.Default.white
        self.view.addSubview(logoImage)
        
        logoImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Bind
    private func bind() {
        viewModel.error
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, err in
                vc.handleError(err)
            })
            .disposed(by: disposeBag)
    }
    
    private func handleError(_ err: Error) {
        guard DataRequestError.isHandledError(err: err) == false else {
            return
        }
        
        alertManager.showDefatulErrorMessage(completion: { [weak self] in
            self?.viewModel.showSignInFlow()
        })
    }
    
    private func checkAccount() {
        viewModel.checkEntry()
    }
}
