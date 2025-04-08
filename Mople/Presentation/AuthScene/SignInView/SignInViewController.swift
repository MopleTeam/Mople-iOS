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

final class SignInViewController: DefaultViewController, View {
    
    typealias Reactor = SignInViewReactor
    
    // MARK: - Variables
    var disposeBag = DisposeBag()
    
    // MARK: - UI Components
    private let titleContainerView = UIView()
    
    private let appImageView: UIImageView = {
        let view = UIImageView()
        view.image = .launchScreenIcon
        view.contentMode = .center
        return view
    }()

    private let subTitle: UILabel = {
        let label = UILabel()
        label.text = TextStyle.App.subTitle
        label.font = FontStyle.Title3.medium
        label.textColor = ColorStyle.Gray._03
        label.textAlignment = .center
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [appImageView, subTitle])
        sv.axis = .vertical
        sv.spacing = 16
        sv.alignment = .fill
        sv.distribution = .fill
        sv.setContentHuggingPriority(.defaultLow, for: .vertical)
        return sv
    }()
    
    private let kakaoLoginButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Login.kakao,
                        font: FontStyle.Title3.semiBold,
                        normalColor: ColorStyle.Gray._01)
        
        btn.setImage(image: .kakao,
                        imagePlacement: .leading,
                        contentPadding: 8)
        btn.setBgColor(normalColor: ColorStyle.Default.yellow)
        btn.setRadius(8)
        return btn
    }()
    
    private let appleLoginButton: BaseButton = {
        let btn = BaseButton()
        btn.setTitle(text: TextStyle.Login.apple,
                        font: FontStyle.Title3.semiBold,
                        normalColor: ColorStyle.Default.white)
        
        btn.setImage(image: .apple,
                        imagePlacement: .leading,
                        contentPadding: 8)
        btn.setBgColor(normalColor: ColorStyle.Default.black)
        btn.setRadius(8)
        return btn
    }()
    
    private lazy var loginStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [kakaoLoginButton, appleLoginButton])
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
        return sv
    }()
    
    // MARK: - LifeCycle
    init(reactor: SignInViewReactor) {
        super.init()
        self.reactor = reactor
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
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview()
                .inset(UIScreen.getDefaultBottomPadding())
        }
        
        titleStackView.snp.makeConstraints { make in
            make.center.equalTo(titleContainerView)
            make.horizontalEdges.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview() 
            make.bottom.lessThanOrEqualToSuperview()
        }
        
        appleLoginButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
        
        kakaoLoginButton.snp.makeConstraints { make in
            make.height.equalTo(56)
        }
    }
    
    // MARK: - Binding
    func bind(reactor: SignInViewReactor) {
        self.appleLoginButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.appleLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        self.kakaoLoginButton.rx.controlEvent(.touchUpInside)
            .map { _ in Reactor.Action.kakaoLogin }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        #warning("여기 고쳐야해")
        reactor.pulse(\.$message)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, message in
//                vc.alertManager.showAlert(title: "로그인 에러", message: message)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

