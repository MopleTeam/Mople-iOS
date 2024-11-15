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
    
    typealias Reactor = LoginViewReactor
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleContainerView = UIView()
    
    private let mainTitle : UILabel = {
        let label = UILabel()
        label.text = TextStyle.App.title
        label.font = FontStyle.App.title
        label.textColor = ColorStyle.App.primary
        label.textAlignment = .center
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = UILabel()
        label.text = TextStyle.App.subTitle
        label.font = FontStyle.Title3.regular
        label.textColor = ColorStyle.Gray._05
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
    
    private let kakaoLoginButton: BaseButton = {
        let button = BaseButton()
        button.setTitle(text: TextStyle.Login.kakao,
                        font: FontStyle.Title3.semiBold,
                        color: ColorStyle.Gray._01)
        
        button.setImage(image: .kakao,
                        imagePlacement: .leading,
                        contentPadding: 8)
        button.setBgColor(ColorStyle.Default.yellow)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let appleLoginButton: BaseButton = {
        let button = BaseButton()
        button.setTitle(text: TextStyle.Login.apple,
                        font: FontStyle.Title3.semiBold,
                        color: ColorStyle.Default.white)
        
        button.setImage(image: .apple,
                        imagePlacement: .leading,
                        contentPadding: 8)
        button.setBgColor(ColorStyle.Default.black)
        button.layer.cornerRadius = 8
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
        sv.backgroundColor = .systemYellow
        sv.axis = .vertical
        sv.spacing = 0
        sv.alignment = .fill
        sv.distribution = .fill
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 0,
                                 left: 20,
                                 bottom: UIScreen.hasNotch() ? 0 : 28,
                                 right: 20)
        return sv
    }()
    
    // MARK: - LifeCycle
    init(reactor: LoginViewReactor) {
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
            make.edges.equalToSuperview()
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
    
    // MARK: - Binding
    func bind(reactor: LoginViewReactor) {
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
