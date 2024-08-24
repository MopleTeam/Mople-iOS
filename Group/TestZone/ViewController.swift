//
//  ViewController.swift
//  Group_Project
//
//  Created by CatSlave on 7/11/24.

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import AuthenticationServices
import PhotosUI

class ViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let scr = UIScrollView()
        scr.showsHorizontalScrollIndicator = true
        return scr
    }()
    
    private let scrollContentView = UIView()
            
    private let loginTokenTitle: UILabel = {
        let label = UILabel()
        label.text = "Apple Token"
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    private let accessTokenLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .systemOrange
        label.layer.cornerRadius = 5
        label.text = "access Tokenaccess"
        label.layer.masksToBounds = true
        return label
    }()
    
    private let refreshTokenLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .systemOrange
        label.layer.cornerRadius = 5
        label.text = "refresh Token"
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var loginTokenStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [loginTokenTitle, accessTokenLabel, refreshTokenLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.spacing = 10
        sv.alignment = .fill
        return sv
    }()
    
    private let tokenTitle: UILabel = {
        let label = UILabel()
        label.text = "Device Token"
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    private let pasteButton: UIButton = {
        let button = UIButton()
        button.setTitle("Paste", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private lazy var tokenTopStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [tokenTitle, pasteButton])
        sv.axis = .horizontal
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    private let tokenLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .systemOrange
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.text = "Device Token"
        return label
    }()
    
    private lazy var tokenStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [tokenTopStackView, tokenLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    
    private let apsTitle: UILabel = {
        let label = UILabel()
        label.text = "Apple Push Service"
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    private let apsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.backgroundColor = .systemOrange
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.text = "APS Json"
        return label
    }()
    
    private lazy var apsStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [apsTitle, apsLabel])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        return sv
    }()
    

    
    private let serverUrlTitle: UILabel = {
        let label = UILabel()
        label.text = "Server Url"
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    private let serverTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .systemYellow
        field.borderStyle = .roundedRect
        field.clearButtonMode = .always
        field.placeholder = "Server Url"
        return field
    }()
    
    private lazy var inputUrl: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [serverUrlTitle, serverTextField])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 10
        return sv
    }()
    
    private let enterUrlTitle: UILabel = {
        let label = UILabel()
        label.text = "Enter Url"
        label.font = .systemFont(ofSize: 30)
        return label
    }()
    
    private let enterUrlTextField: UITextField = {
        let field = UITextField()
        field.backgroundColor = .systemYellow
        field.borderStyle = .roundedRect
        field.placeholder = "Enter Url"
        field.isEnabled = false
        return field
    }()
    
    private lazy var enterUrl: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [enterUrlTitle, enterUrlTextField])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 10
        return sv
    }()
    
    private let loginButton = {
        let loginBtn = ASAuthorizationAppleIDButton(type: .signIn, style: .black)
        return loginBtn
    }()
    
    private let imagePickerButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("사진첩", for: .normal)
        btn.backgroundColor = .systemRed.withAlphaComponent(0.2)
        return btn
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemYellow
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var infoView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [loginTokenStackView, tokenStackView, apsStackView, inputUrl, enterUrl, loginButton, imagePickerButton])
        sv.axis = .vertical
        sv.distribution = .fill
        sv.alignment = .fill
        sv.spacing = 20
        sv.isLayoutMarginsRelativeArrangement = true
        sv.layoutMargins = .init(top: 10, left: 10, bottom: 10, right: 10)
        return sv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupGesture()
        setupUI()
        setupAction()
        setupNavi()
        setupLoginTokenLabel()
    }
    
    // MARK: - Keyboard Event Setup
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupKeyboardEvent()
        self.navigationController?.navigationBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(setupApsLabel), name: .urlSaved, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setupLabel), name: .deviceTokenSaved, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        removeKeyboardObserver()
    }
    
    override func viewDidLayoutSubviews() {
        let radius = self.imageView.frame.width/2
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.cornerRadius = radius
    }
    
    private func setupNavi() {
        self.navigationItem.title = "Test Zone"
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let rightItem = UIBarButtonItem(title: "이동", style: .plain, target: self, action: #selector(presentLoginView))
        
        self.navigationItem.rightBarButtonItem = rightItem
    }
    
    @objc private func presentLoginView() {
//        self.navigationController?.pushViewController(LoginViewController(), animated: true)
    }
    
    @objc private func setupApsLabel() {
        self.apsLabel.text = LocalDataManager.shared.loadEnterUrl()
    }
    
    @objc private func setupLabel() {
        self.tokenLabel.text = LocalDataManager.shared.loadToken()
    }
    
    private func setupLoginTokenLabel() {
        
        if let token = TokenKeyChain().getToken() {
            
            self.accessTokenLabel.text = token.accessToken
            self.refreshTokenLabel.text = token.refreshToken
            
        } else {
            self.accessTokenLabel.text = "토큰 불러오기 실패"
            self.refreshTokenLabel.text = "토큰 불러오기 실패"
        }
    }
    
    func setEnteredUrl(urlString: String?) {
        print(#function)
        self.enterUrlTextField.text = urlString
    }
    
    private func setupUI() {
        self.scrollView.delegate = self
        self.view.backgroundColor = .white
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(scrollContentView)
        self.scrollContentView.addSubview(infoView)
        self.scrollContentView.addSubview(imageView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(self.view.safeAreaLayoutGuide)
        }

        scrollContentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        infoView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(scrollContentView)
        }
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(infoView.snp.bottom)
            make.size.equalTo(300)
            make.bottom.centerX.equalTo(scrollContentView)
        }
    }
    
    private func loginButtonTapped() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func setupAction() {
        loginButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.loginButtonTapped()
            })
            .disposed(by: disposeBag)
        
        imagePickerButton.rx.controlEvent(.touchUpInside)
            .subscribe(with: self, onNext: { vc, _ in
                vc.requestPhotoLibraryPermission()
            })
            .disposed(by: disposeBag)
        
        pasteButton.rx.tap
            .subscribe(with: self, onNext: { vc, _ in
                if let token = vc.tokenLabel.text {
                    UIPasteboard.general.string = token
                    vc.presentAlert(message: "복사완료")
                }
            })
            .disposed(by: disposeBag)
    }
    
    fileprivate func setupGesture() {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(endEditAction))
        gesture.delegate = self
        self.view.addGestureRecognizer(gesture)
    }
    
    @objc fileprivate func endEditAction() {
        self.view.endEditing(true)
    }
    
    func requestPhotoLibraryPermission() {
        
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch status {
                case .authorized:
                    print("사진 라이브러리 접근 권한이 허용되었습니다.")
                    self.configureImagePicker()
                case .limited:
                    print("사진 라이브러리 접근 일부 허용")
                    self.configureImagePicker()
                case .denied, .restricted:
                    print("사진 라이브러리 접근 권한이 거부되었습니다.")
                    // 사용자에게 설정에서 권한을 허용하도록 안내합니다.
                case .notDetermined:
                    print("사진 라이브러리 접근 권한이 아직 결정되지 않았습니다.")
                @unknown default:
                    break
                }
            }
        }
    }
    
    func configureImagePicker(){
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let pickerViewController = PHPickerViewController(configuration: configuration)
        
        pickerViewController.delegate = self
        present(pickerViewController, animated: true)
    }
}

// MARK: - Alert
extension ViewController {
    private func presentAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("닫기", comment: "Default action"), style: .cancel))
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - KeyBoard Event
extension ViewController: KeyboardEvent {
    var contentView: UIView {
        self.scrollContentView
    }
    
    var transformView: UIView {
        self.view
    }
    
    var transformScrollView: UIScrollView {
        self.scrollView
    }
}

// MARK: - Gesture
extension ViewController : UIGestureRecognizerDelegate {
    
    // gesture 감지 후 어떤 view에서 touch됐는지 감지 가능
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is ASAuthorizationAppleIDButton {
            print("애플 로그인 탭")
            return false
        } else {
            print("view 탭")
            return true
        }
    }
}

// MARK: - ScrollViewDelegate
extension ViewController: UIScrollViewDelegate {
    // 움직이기 시작할 때
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.serverTextField.resignFirstResponder()
    }
}

// MARK: - Apple Login Test

extension ViewController {
    private func codeTest(code: String, url: String) {
        ServerAPI.shared.apiTest(url: url, authorizationCode: code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(_):
                    self.presentAlert(message: "성공")
                case .failure(let error):
                    self.presentAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func loginTest(code: String) {
        ServerAPI.shared.loginTest(authrizationCode: code) { [weak self] result in
            
            guard let self = self else {
                return
            }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    print("token success")
                    TokenKeyChain().saveToken(token)
                    self.setupLoginTokenLabel()
                    ServerAPI.shared.getUserInfo()
                    
                    
                case .failure(let error):
                    self.presentAlert(message: error.localizedDescription)
                }
            }
        }
    }
}

extension ViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension ViewController: ASAuthorizationControllerDelegate  {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleLogin = authorization.credential as? ASAuthorizationAppleIDCredential {
            
//            guard let idCode = appleLogin.authorizationCode else { return }
//            
//            let codeString = String(decoding: idCode, as: UTF8.self)
//            
//            
//            print("codeString : \(codeString)")
//            self.loginTest(code: codeString)
//            
//            guard let url = serverTextField.text, !url.isEmpty else { return }
//            
//            self.codeTest(code: codeString, url: url)
        }
    }
}

// MARK: - Photos
#warning("사진을 크게 확인 할 수 있는 뷰로 전환")
extension ViewController: PHPickerViewControllerDelegate {
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        if let itemprovider = results.first?.itemProvider{
            
            if itemprovider.canLoadObject(ofClass: UIImage.self){
                itemprovider.loadObject(ofClass: UIImage.self) { image , error  in
                    
                    if let error{
                        print(error)
                    }
                    if let selectedImage = image as? UIImage{
                        DispatchQueue.main.async {
//
                            self.imageView.image = selectedImage
                        }
                    }
                }
            }
            
        }
    }
}

