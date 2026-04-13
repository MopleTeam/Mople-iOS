//
//  DefaultTextView.swift
//  Mople
//
//  Created by CatSlave on 7/17/25.
//

import UIKit
import Domain
import SnapKit
import RxSwift
import RxCocoa

struct MessageInfo {
    var text: String
    var mentionList: [Int] = []
}

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
    private let shouldUpdateHeight: Bool
    private var maxCount: Int?
    
    public var cursorLocation: NSRange { textView.selectedRange }
    
    public var messageInfo: MessageInfo? {
        let info = textView.getServerTextWithMentions()
        guard !info.text.isEmpty else { return nil }
        return .init(text: info.text, mentionList: info.mentionIds)
    }
    
    private var maxHeight: CGFloat {
        let lineHeight = textView.font?.lineHeight ?? 0
        return lineHeight * CGFloat(maxTextLine)
    }
    
    private var minHeight: CGFloat { 20 }
    public var maxTextLine: Int = 4
    private var textViewHeightConstraint: Constraint?
    private var selectionChangeWorkItem: DispatchWorkItem?
    
    // MARK: - Observable
    fileprivate let editingObservable: BehaviorRelay<Bool> = .init(value: false)
    fileprivate let cursor: PublishSubject<Void> = .init()
    
    // MARK: - UI Components
    public let textView: UITextView = {
        let textView = UITextView()
        textView.font = FontStyle.Body1.regular
        textView.textColor = .text01
        textView.tintColor = .text02
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
        label.textColor = .text04
        return label
    }()
    
    init(shouldUpdateHeight: Bool = true) {
        self.shouldUpdateHeight = shouldUpdateHeight
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

// MARK: - Configure
extension DefaultTextView {
    public func updateInset(_ inset: UIEdgeInsets) {
        textView.snp.remakeConstraints { make in
            make.leading.equalToSuperview().inset(inset.left)
            make.trailing.equalToSuperview().inset(inset.right)
            make.top.equalToSuperview().inset(inset.top)
            make.bottom.equalToSuperview().inset(inset.bottom)
        }
    }
    
    public func addMention(text: String, id: Int) {
        self.textView.addMention(text: text, id: id)
        hidePlaceHolder()
        updateTextViewHeight()
    }
    
    public func setMessage(text: String, mentions: [UserInfo]) {
        self.textView.setTextFromServer(text: text, mentions: mentions)
        hidePlaceHolder()
        updateTextViewHeight()
    }
    
    public func setPlaceholderText(text: String) {
        self.placeHolder.text = text
    }
    
    public func hidePlaceHolder() {
        placeHolder.isHidden = !textView.text.isEmpty
    }
    
    public func setMaxCount(_ count: Int) {
        self.maxCount = count
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
        updateTextViewHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if let maxCount {
            let currentCount = textView.text.count
            let addedCount = text.count - range.length
            let newCount = currentCount + addedCount
            
            return newCount <= maxCount
        }
        
        textView.resetTypingAttributes()
        if text.isEmpty && range.length == 1 {
            let deleteLocation = range.location
            if let mentionRange = textView.getMentionRange(at: deleteLocation) {
                DispatchQueue.main.async {
                    textView.deleteMentionRange(mentionRange)
                }
                return false
            }
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        hidePlaceHolder()
        cursor.onNext(())
        selectionChangeWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.textView.handleSelectionConfirmed()
        }
        selectionChangeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
}

// MARK: - Helper
extension DefaultTextView {
    func updateTextViewHeight() {
        guard shouldUpdateHeight else { return }
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
    
    func filterMention() -> String? {
        guard let attributedText = textView.attributedText,
              !attributedText.string.isEmpty else { return nil }
        
        let cursorLocation = textView.selectedRange.location
        guard cursorLocation > 0 else { return nil }
        
        // 커서 바로 앞 문자가 멘션 어트리뷰트인지 체크
        if cursorLocation <= attributedText.length {
            let checkLocation = cursorLocation - 1
            let attributes = attributedText.attributes(at: checkLocation, effectiveRange: nil)
            if attributes[NSAttributedString.Key(rawValue: "MentionTag")] != nil {
                return nil
            }
        }
        
        // ✅ 수정: NSString 사용하여 UTF-16 기준으로 처리
        let text = attributedText.string as NSString
        let beforeCursorRange = NSRange(location: 0, length: cursorLocation)
        let beforeCursorText = text.substring(with: beforeCursorRange)
        
        let words = beforeCursorText.components(separatedBy: " ")
        guard let lastWord = words.last, lastWord.hasPrefix("@") else { return nil }
        
        return String(lastWord.dropFirst())
    }
}

extension Reactive where Base: DefaultTextView {
    var text: Observable<String?> {
        return base.textView.rx.text
            .asObservable()
    }
    
    var mention: Observable<String?> {
        return base.cursor
            .map({ _ in base.filterMention() })
            .asObservable()
    }
    
    var isResign: Binder<Bool> {
        return base.textView.rx.isResign
    }
    
    var isEditMode: Observable<Bool> {
        return base.editingObservable.asObservable()
    }
}



