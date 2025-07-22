//
//  DefaultTextView.swift
//  Mople
//
//  Created by CatSlave on 7/17/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class DefaultTextView: UIView {
    
    // MARK: - Variables
    public var text: String? {
        get { textView.text }
        set {
            textView.text = newValue
            updateTextViewHeight()
            hidePlaceHolder()
        }
    }
    
    private var maxHeight: CGFloat {
        let lineHeight = textView.font?.lineHeight ?? 0
        return lineHeight * CGFloat(maxTextLine)
    }
    
    private var minHeight: CGFloat { 20 }
    public var maxTextLine: Int = 4
    private var textViewHeightConstraint: Constraint?
    
    
    // MARK: - Observable
    fileprivate let editingObservable: BehaviorRelay<Bool> = .init(value: false)

    // MARK: - UI Components
    fileprivate let textView: UITextView = {
        let textView = UITextView()
        textView.font = FontStyle.Body1.regular
        textView.textColor = .gray02
        textView.tintColor = .gray02
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 0
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return textView
    }()
    
    private let placeHolder: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body1.regular
        label.textColor = .gray05
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        setLayout()
        setTextView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setLayout() {
        self.backgroundColor = .bgInput
        self.layer.cornerRadius = 8
        self.addSubview(textView)
        self.textView.addSubview(placeHolder)
        
        textView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(8)
            make.verticalEdges.equalToSuperview().inset(18)
            textViewHeightConstraint = make.height.greaterThanOrEqualTo(20).constraint
        }
        
        placeHolder.snp.makeConstraints { make in
            make.leading.top.equalToSuperview()
        }
    }
    
    private func setTextView() {
        textView.delegate = self
    }
}

// MARK: - PlaceHolder
extension DefaultTextView {
    public func setPlaceholderText(text: String) {
        self.placeHolder.text = text
    }
    
    public func hidePlaceHolder() {
        placeHolder.isHidden = !textView.text.isEmpty
    }
}

// MARK: - Delegate
extension DefaultTextView: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        editingObservable.accept(false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        editingObservable.accept(true)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        hidePlaceHolder()
        updateTextViewHeight()
    }
}

// MARK: - Helper
extension DefaultTextView {
    func updateTextViewHeight() {
        // 높이 제한 없이 텍스트뷰가 필요로 하는 만큼 계산
        let fittingSize = CGSize(width: textView.frame.width,
                                 height: .greatestFiniteMagnitude)
        let expectedSize = textView.sizeThatFits(fittingSize)
        
        // max height와 텍스트뷰 최대 높이 중 낮은 것
        let expectedHeight = min(expectedSize.height, maxHeight)
        let clampedExpectedHeight = max(expectedHeight, minHeight)
        
        let roundedCurrent = round(textView.frame.height * 100) / 100
        let roundedExpected = round(clampedExpectedHeight * 100) / 100

        // 현재 텍스트뷰 높이와 조정할 높이가 같지 않다면?
        if roundedCurrent != roundedExpected {
            textView.isScrollEnabled = expectedSize.height > maxHeight
            textViewHeightConstraint?.update(offset: clampedExpectedHeight)
        }
    }
}

extension Reactive where Base: DefaultTextView {
    var text: Observable<String?> {
        return base.textView.rx.text
            .asObservable()
    }
    
    var isResign: Binder<Bool> {
        return base.textView.rx.isResign
    }
    
    var isEditMode: Observable<Bool> {
        return base.editingObservable.asObservable()
    }
}
