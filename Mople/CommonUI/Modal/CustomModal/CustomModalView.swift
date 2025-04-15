//
//  CustomModalView.swift
//  Mople
//
//  Created by CatSlave on 4/15/25.
//

import UIKit
import RxSwift
import SnapKit

final class CustomModalView: UIView {
    
    // MARK: - Variables
    private var disposeBag = DisposeBag()
    private let modalHeight: CGFloat = 195
    private let opacity: CGFloat = 0.5
    
    // MARK: - Observable
    private let dismiss: PublishSubject<Void> = .init()
    public var dismissObservable: Observable<Void> {
        return dismiss.asObserver()
    }
    
    // MARK: - Gesture
    private let panGesture = UIPanGestureRecognizer()
    
    // MARK: - UI Components
    private let contentView: UIView
    
    private let mainView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.Default.white
        view.layer.makeCornes(radius: 20, corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner])
        return view
    }()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.App.tertiary
        view.layer.cornerRadius = 3
        return view
    }()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = ColorStyle.Default.white
        return view
    }()
    
    init(contentView: UIView) {
        self.contentView = contentView
        super.init(frame: .zero)
        setupUI()
        setGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        initialSetup()
    }
    
    private func initialSetup() {
        DispatchQueue.main.async { [weak self] in
            self?.resetModal()
        }
    }
    
    private func setupUI() {
        self.backgroundColor = ColorStyle.Default.black.withAlphaComponent(0)

        self.addSubview(mainView)
        mainView.addSubview(grabberView)
        mainView.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        mainView.snp.makeConstraints { make in
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
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
    }
    
    private func setGesture() {
        self.addGestureRecognizer(panGesture)
        
        panGesture.rx.event
            .filter({ [weak self] in
                guard let self else { return false }
                return $0.translation(in: self).y >= 0
            })
            .bind(with: self, onNext: { view, gesture in
                view.handlePanGesture(gesture: gesture)
            })
            .disposed(by: disposeBag)
    }
    
    private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let velocity = gesture.velocity(in: self).y
        let translationY = gesture.translation(in: self).y
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
    private func downModal() {
        UIView.animate(withDuration: 0.33,
                       animations: { [weak self] in
            guard let self else { return }
            changeBottomOffset(offset: modalHeight)
            changeOpacity(opacity: 0)
            layoutIfNeeded()
        }, completion: { [weak self] _ in
            self?.dismiss.onNext(())
        })
    }
    
    // 기본상태로 되돌리기
    public func resetModal() {
        UIView.animate(withDuration: 0.33,
                       animations: { [weak self] in
            guard let self else { return }
            changeBottomOffset(offset: 0)
            changeOpacity(opacity: opacity)
            layoutIfNeeded()
        })
    }
    
    // 모달 내림 정도 조정
    private func changeBottomOffset(offset: CGFloat) {
        mainView.snp.updateConstraints { make in
            make.bottom.equalToSuperview().offset(offset)
        }
    }
    
    // 배경 투명도 조정
    private func changeOpacity(opacity: CGFloat) {
        backgroundColor = backgroundColor?.withAlphaComponent(opacity)
    }
}

extension CustomModalView {
    static func makeModalButton(title: String?,
                                image: UIImage?) -> BaseButton {
        let btn = BaseButton()
        btn.setButtonAlignment(.leading)
        btn.setTitle(text: title,
                     font: FontStyle.Body1.medium,
                     normalColor: ColorStyle.Gray._02)
        btn.setLayoutMargins(inset: .init(top: 16, leading: 20, bottom: 16, trailing: 20))
        btn.setImage(image: image,
                     imagePlacement: .leading,
                     contentPadding: 8)
        btn.setBgColor(normalColor: ColorStyle.Default.white,
                       selectedColor: ColorStyle.BG.primary)
        return btn
    }
}

