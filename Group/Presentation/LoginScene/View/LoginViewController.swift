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
    
    private let kakaoLoginButton: IconLabelButton = {
        let button = IconLabelButton(configure: AppDesign.Login.kakao,
                                     iconSize: 22,
                                     iconAligment: .left,
                                     contentSpacing: 8)
        button.setRadius(8)
        button.setBackColor(AppDesign.Login.kakaoColor)
        return button
    }()
    
    private let appleLoginButton: IconLabelButton = {
        let button = IconLabelButton(configure: AppDesign.Login.apple,
                                     iconSize: 22,
                                     iconAligment: .left,
                                     contentSpacing: 8)
        button.setRadius(8)
        button.setBackColor(AppDesign.Login.appleColor)
        return button
    }()
    
    private lazy var loginStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [appleLoginButton, kakaoLoginButton])
        sv.axis = .vertical
        sv.spacing = 8
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleContainerView, loginStackView])
        sv.axis = .vertical
        sv.spacing = 0
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 0,
                                 left: 20,
                                 bottom: UIScreen.safeBottom(),
                                 right: 20)
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
        self.view.addSubview(mainStackView)
        self.titleContainerView.addSubview(titleStackView)

        mainStackView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        titleStackView.snp.makeConstraints { make in
            make.center.equalTo(titleContainerView)
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    // MARK: - Selectors
    func bind(reactor: LoginViewReacotr) {
        self.appleLoginButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.appleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.kakaoLoginButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.kakaoLogin }
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

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}






