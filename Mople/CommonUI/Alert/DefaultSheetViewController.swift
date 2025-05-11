//
//  MapSelectView.swift
//  Mople
//
//  Created by CatSlave on 4/15/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DefaultSheetViewController: UIViewController {
    
    // MARK: - Closure
    private var cancleAction: (() -> Void)? = nil
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    private let modalHeight: CGFloat = 195
    private let opacity: CGFloat = 0.5
    
    // MARK: - Gesture
    private let panGesture = UIPanGestureRecognizer()
    private let tapGesture = UITapGestureRecognizer()
        
    // MARK: - UI Components
    
    private let sheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .defaultWhite
        view.layer.makeCornes(radius: 20, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        view.layer.makeShadow(opactity: 0.1,
                              radius: 16)
        return view
    }()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .appTertiary
        view.layer.cornerRadius = 3
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .defaultWhite
        return view
    }()
    
    private lazy var buttonStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
        
    // MARK: - LifeCycle
    init(actions: [DefaultSheetAction],
         cancleAction: (() -> Void)? = nil) {
        super.init(nibName: nil, bundle: nil)
        self.cancleAction = cancleAction
        addButtons(actions: actions)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetModal()
    }
    
    // MARK: - Initial Setup
    private func initialSetup() {
        self.modalPresentationStyle = .overFullScreen
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.view.addSubview(sheetView)
        sheetView.addSubview(grabberView)
        sheetView.addSubview(scrollView)
        scrollView.addSubview(buttonStackView)
        
        sheetView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview().offset(modalHeight)
            make.height.equalTo(modalHeight)
        }
        
        grabberView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
            make.height.equalTo(5)
            make.width.equalTo(80)
        }
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(grabberView.snp.bottom).offset(16)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
    }
    
    private func setGesture() {
        self.view.addGestureRecognizer(panGesture)
        self.view.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.downModal()
            })
            .disposed(by: disposeBag)
        
        panGesture.rx.event
            .filter({ [weak self] in
                guard let self else { return false }
                return $0.translation(in: self.view).y >= 0
            })
            .bind(with: self, onNext: { view, gesture in
                view.handlePanGesture(gesture: gesture)
            })
            .disposed(by: disposeBag)
    }

    private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self.view).y
        let translationY = gesture.translation(in: self.view).y
        let adjustOpacity = opacity - opacity * translationY / modalHeight

        switch gesture.state {
        case .changed:
            changeOpacity(opacity: adjustOpacity)
            handleChangedGesture(translationY: translationY)
        case .ended:
            handleEndedGesture(translationY: translationY,
                               velocityY: velocity)
        default:
            break
        }
    }
    
    // 제스처 진행 핸들링
    private func handleChangedGesture(translationY: CGFloat) {
        if translationY > modalHeight {
            downModal()
        } else {
            changeBottomOffset(offset: translationY)
        }
    }
    
    // 제스처 종료 핸들링
    private func handleEndedGesture(translationY: CGFloat, velocityY: CGFloat) {
        let modalHalfHeight = modalHeight / 2
        if translationY > modalHalfHeight || velocityY > 300 {
            downModal()
        } else {
            resetModal()
        }
    }
    
    // 모달 dismiss
    private func downModal(completion: (() -> Void)? = nil) {
        UIView.animate(withDuration: 0.33,
                       animations: { [weak self] in
            guard let self else { return }
            changeBottomOffset(offset: modalHeight)
            changeOpacity(opacity: 0)
            self.view.layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.dismiss(animated: true,
                          completion: completion ?? self?.cancleAction)
        })
    }
    
    // 기본상태로 되돌리기
    public func resetModal() {
        UIView.animate(withDuration: 0.33,
                       animations: { [weak self] in
            guard let self else { return }
            changeBottomOffset(offset: 0)
            changeOpacity(opacity: opacity)
            self.view.layoutIfNeeded()
        })
    }
    
    // 모달 내림 정도 조정
    private func changeBottomOffset(offset: CGFloat) {
        sheetView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(offset)
        }
    }
    
    // 배경 투명도 조정
    private func changeOpacity(opacity: CGFloat) {
        let backColor: UIColor = .defaultBlack
        self.view.backgroundColor = backColor.withAlphaComponent(opacity)
    }
}

extension DefaultSheetViewController {
    private func addButtons(actions: [DefaultSheetAction]) {
        actions.forEach {
            let button = actionButtonBulider(action: $0)
            buttonStackView.addArrangedSubview(button)
        }
    }
    
    private func actionButtonBulider(action: DefaultSheetAction) -> BaseButton {
        let btn = BaseButton()
        btn.setButtonAlignment(.leading)
        btn.setTitle(text: action.text,
                     font: FontStyle.Body1.medium,
                     normalColor: .gray02)
        btn.setLayoutMargins(inset: .init(top: 16, leading: 20, bottom: 16, trailing: 20))
        btn.setImage(image: action.image,
                     imagePlacement: .leading,
                     contentPadding: 8)
        btn.setBgColor(normalColor: .defaultWhite,
                       highlightColor: .bgPrimary)
        btn.addAction(makeAction(action.completion),
                      for: .touchUpInside)
        return btn
    }
    
    private func makeAction(_ action: (() -> Void)?) -> UIAction {
        return .init { [weak self] _ in
            self?.downModal(completion: action)
        }
    }
}

