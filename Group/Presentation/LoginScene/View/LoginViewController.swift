//
//  LoginViewController.swift
//  Group
//
//  Created by CatSlave on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import ReactorKit
import AuthenticationServices

final class LoginViewController: UIViewController, View {
    typealias Reactor = LoginViewReacotr
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleContainerView = UIView()
    
    private let mainTitle : UILabel = {
        let label = BaseLabel(configure: AppDesign.Login.title)
        label.textAlignment = .center
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = BaseLabel(configure: AppDesign.Login.subTitle)
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
    
    // MARK: - LifeCycle
    init(reactor: LoginViewReacotr) {
        defer { self.reactor = reactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
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
    
    // MARK: - Selectors
    func bind(reactor: LoginViewReacotr) {
        self.loginButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.executeLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state
            .compactMap { $0.errorMessage }
            .subscribe(onNext: { message in
                print("로그인 에러 발생 : \(message)")
            })
            .disposed(by: disposeBag)
    }
}

