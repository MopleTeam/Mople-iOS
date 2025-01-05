//
//  ProfileCreateViewController.swift
//  Group
//
//  Created by CatSlave on 8/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import ReactorKit
import SnapKit
import PhotosUI

class SignUpViewController: UIViewController, View {
    typealias Reactor = SignUpViewReactor
    
    var disposeBag = DisposeBag()
    
    // MARK: - Sub Reactor
    let profileSetupReactor: ProfileSetupViewReactor
    
    // MARK: - Observable
    private let completionObservable: PublishSubject<(nickname: String, image: UIImage?)> = .init()
    private let loadingObservable: PublishSubject<Bool> = .init()
    
    // MARK: - UI Components
    private let mainTitle: UILabel = {
        let label = UILabel()
        label.text = TextStyle.ProfileSetup.title
        label.font = FontStyle.Heading.bold
        label.textColor = ColorStyle.Gray._01
        label.numberOfLines = 2
        return label
    }()
    
    private let profileContainerView = UIView()
    
    private lazy var profileSetupView: ProfileSetupViewController = {
        let viewController = ProfileSetupViewController(type: .create,
                                                        reactor: profileSetupReactor,
                                                        lodingObserver: loadingObservable.asObserver(),
                                                        completionObserver: completionObservable.asObserver())
        return viewController
    }()
    
    // MARK: - Indicator
    fileprivate let indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.layer.zPosition = 1
        return indicator
    }()
    
    // MARK: - LifeCycle
    init(profileSetupReactor: ProfileSetupViewReactor,
         signUpReactor: SignUpViewReactor) {
        print(#function, #line, "LifeCycle Test signUp Created" )
        self.profileSetupReactor = profileSetupReactor
        defer { self.reactor = signUpReactor }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print(#function, #line, "LifeCycle Test signUp Deinit" )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        setupLayout()
        addProfileSetupView()
    }

    private func setupLayout() {
        self.view.backgroundColor = .white
        self.view.addSubview(mainTitle)
        self.view.addSubview(profileContainerView)
        self.view.addSubview(indicator)

        mainTitle.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).inset(28)
            make.horizontalEdges.equalToSuperview().inset(20)
        }

        profileContainerView.snp.makeConstraints { make in
            make.top.equalTo(mainTitle.snp.bottom).offset(24)
            make.horizontalEdges.equalTo(mainTitle.snp.horizontalEdges)
            make.bottom.equalToSuperview().inset(UIScreen.getAdditionalBottomInset())
        }

        indicator.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func addProfileSetupView() {
        addChild(profileSetupView)
        profileContainerView.addSubview(profileSetupView.view)
        profileSetupView.didMove(toParent: self)
        profileSetupView.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    // MARK: - Binding
    func bind(reactor: SignUpViewReactor) {
        rx.viewWillAppear
            .map { _ in Reactor.Action.getRandomNickname }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        loadingObservable
            .map({ Reactor.Action.setLoading(isLoad: $0) })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        completionObservable
            .debug()
            .map { Reactor.Action.singUp(name: $0.nickname, image: $0.image) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$randomName)
            .asDriver(onErrorJustReturn: nil)
            .compactMap { $0 }
            .drive(with: self, onNext: { vc, nickname in
                vc.profileSetupView.setRandomNickname(nickname)
            })
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$isLoading)
            .asDriver(onErrorJustReturn: false)
            .drive(self.rx.isLoading)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: SignUpViewController {
    var isLoading: Binder<Bool> {
        return Binder(self.base) { vc, isLoading in
            vc.indicator.rx.isAnimating.onNext(isLoading)
        }
    }
}


