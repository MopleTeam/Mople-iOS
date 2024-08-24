//
//  LoginViewController.swift
//  Group
//
//  Created by CatSlave on 8/12/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import SnapKit
import AuthenticationServices

final class LoginViewController: UIViewController {
    
    private let loginViewModel: LoginViewModel!
    
    var disposeBag = DisposeBag()
    
    private let titleContainerView = UIView()
    
    private let mainTitle : UILabel = {
        let label = DefaultLabel(configure: AppDesign.Login.main)
        label.textAlignment = .center
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = DefaultLabel(configure: AppDesign.Login.sub)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [mainTitle, subTitle])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        sv.setContentHuggingPriority(.defaultLow, for: .vertical)
        return sv
    }()
    
    private let loginButton = {
        let loginBtn = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        loginBtn.setContentHuggingPriority(.defaultHigh, for: .vertical)
        loginBtn.cornerRadius = 8
        return loginBtn
    }()
    
    private lazy var loginStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleContainerView, loginButton])
        sv.axis = .vertical
        sv.spacing = 24
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 0, left: 20, bottom: 28, right: 20)
        return sv
    }()
    
    init(with viewModel: LoginViewModel) {
        self.loginViewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setBinding()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        setupLayout()
        setupNavi()
    }
    
    private func setupNavi() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(loginStackView)
        self.titleContainerView.addSubview(titleStackView)

        loginStackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.center.equalTo(titleContainerView)
        }
        
        loginButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    // MARK: - ViewModel Bind
    private func setBinding() {
        let output = loginViewModel.transform(input: makeInputAction())
        bindingDataState(output)
    }
    
    private func makeInputAction() -> ViewModelInput<Void> {
        let loginAction = loginButton.rx.controlEvent(.touchUpInside).map { _ in }
        return .init(login: loginAction)
    }
    
    #warning("Alert Task")
    private func bindingDataState(_ output: LoginOutput) {
        output.notifyError
            .bind(with: self, onNext: { vc, _ in
                print("에러 발생")
            }).disposed(by: disposeBag)
    }
}

