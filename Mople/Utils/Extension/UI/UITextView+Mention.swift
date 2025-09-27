//
//  UITextView+Mention.swift
//  Mople
//
//  Created by CatSlave on 8/28/25.
//

import UIKit

extension UITextView {
    func addMention(text: String, id: Int) {
        let mentionText = "@\(text)"
        let currentAttributedText = attributedText ?? NSAttributedString()
        let mutableAttributedText = NSMutableAttributedString(attributedString: currentAttributedText)
        var insertPosition = selectedRange.location
        
        // 안전한 범위 체크 후 @ 문자 확인 및 삭제
        if insertPosition > 0 && insertPosition <= mutableAttributedText.length {
            let checkRange = NSRange(location: insertPosition - 1, length: 1)
            let checkString = mutableAttributedText.attributedSubstring(from: checkRange).string
            if checkString == "@" {
                mutableAttributedText.deleteCharacters(in: checkRange)
                insertPosition -= 1
            }
        }
        
        let mentionAttributedString = NSAttributedString(string: mentionText, attributes: [
            .foregroundColor: UIColor.appPrimary,
            .font: FontStyle.Body1.medium,
            NSAttributedString.Key(rawValue: "MentionTag"): id
        ])
        
        mutableAttributedText.insert(mentionAttributedString, at: insertPosition)
        mutableAttributedText.insert(NSAttributedString(string: " "), at: insertPosition + mentionText.count)
        attributedText = mutableAttributedText
        
        let newCursorPosition = insertPosition + mentionText.count + 1
        selectedRange = NSRange(location: newCursorPosition, length: 0)
        resetTypingAttributes()
    }
    
    func getMentionRange(at location: Int) -> NSRange? {
        guard let attributedText = attributedText,
              location >= 0 && location < attributedText.length else { return nil }
        
        var mentionRange: NSRange?
        
        attributedText.enumerateAttribute(
            NSAttributedString.Key(rawValue: "MentionTag"),
            in: NSRange(location: 0, length: attributedText.length),
            options: []
        ) { value, range, stop in
            if value != nil && NSLocationInRange(location, range) {
                mentionRange = range
                stop.pointee = true
            }
        }
        
        return mentionRange
    }
    
    func deleteMentionRange(_ range: NSRange) {
        guard let attributedText = attributedText else { return }
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        mutableAttributedText.deleteCharacters(in: range)
        self.attributedText = mutableAttributedText
        selectedRange = NSRange(location: range.location, length: 0)
        resetTypingAttributes()
    }
    
    func resetTypingAttributes() {
        let defaultAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.gray03,
            .font: FontStyle.Body1.medium
        ]
        typingAttributes = defaultAttributes
    }
    
    func getServerTextWithMentions() -> (text: String, mentionIds: [Int]) {
        guard let attributedText = attributedText else {
            return (text ?? "", [])
        }
        
        print("=== DEBUG START ===")
        print("Original text: \(attributedText.string)")
        
        let mutableString = NSMutableString(string: attributedText.string)
        var mentionIds: [Int] = []
        var mentionRanges: [(range: NSRange, id: Int)] = []
        
        // 모든 멘션 범위와 ID를 먼저 수집
        attributedText.enumerateAttribute(
            NSAttributedString.Key(rawValue: "MentionTag"),
            in: NSRange(location: 0, length: attributedText.length),
            options: []
        ) { value, range, _ in
            if let mentionId = value as? Int {
                let mentionText = attributedText.attributedSubstring(from: range).string
                print("Found mention - ID: \(mentionId), Range: \(range), Text: '\(mentionText)'")
                mentionRanges.append((range: range, id: mentionId))
            }
        }
        
        print("Total mentions found: \(mentionRanges.count)")
        
        // 역순으로 정렬해서 뒤에서부터 처리 (인덱스 변화 방지)
        mentionRanges.sort { $0.range.location > $1.range.location }
        
        // 각 멘션을 XML 태그로 변환
        for mentionInfo in mentionRanges {
            let mentionText = attributedText.attributedSubstring(from: mentionInfo.range).string
            let xmlTag = "<mention id=\(mentionInfo.id)>\(mentionText)</mention>"
            
            print("Converting: '\(mentionText)' -> '\(xmlTag)' at range \(mentionInfo.range)")
            
            mutableString.replaceCharacters(in: mentionInfo.range, with: xmlTag)
            mentionIds.insert(mentionInfo.id, at: 0)
        }
        
        print("Final result: \(mutableString)")
        print("MentionIds: \(mentionIds)")
        print("=== DEBUG END ===")
        
        return (text: mutableString as String, mentionIds: mentionIds)
    }
    
    func setTextFromServer(text: String, mentions: [UserInfo]) {
        var resultText = text
        var mentionRanges: [(range: NSRange, id: Int, nickname: String)] = []
        
        let mentionPattern = #"<mention id=(\d+)>(@[^<]+)</mention>"#
        let regex = try! NSRegularExpression(pattern: mentionPattern)
        let matches = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
        
        var offset = 0
        
        // 순서대로 처리 (역순 아님)
        for match in matches {
            // 오프셋을 적용한 실제 범위 계산
            let adjustedRange = NSRange(location: match.range.location + offset, length: match.range.length)
            let idRange = match.range(at: 1)
            let textRange = match.range(at: 2)
            
            // 원본 텍스트에서 ID 추출
            guard let idSwiftRange = Range(idRange, in: text),
                  let textSwiftRange = Range(textRange, in: text) else { continue }
            
            let mentionIdString = String(text[idSwiftRange])
            guard let mentionId = Int(mentionIdString) else { continue }
            
            let currentNickname = mentions.first { $0.id == mentionId }?.name
            let displayText = currentNickname != nil ? "@\(currentNickname!)" : String(text[textSwiftRange])
            
            // 현재 resultText에서 교체
            resultText = (resultText as NSString).replacingCharacters(in: adjustedRange, with: displayText)
            
            // 새로운 범위로 저장
            let newRange = NSRange(location: adjustedRange.location, length: displayText.utf16.count)
            mentionRanges.append((range: newRange, id: mentionId, nickname: displayText))
            
            // 오프셋 조정 (새 길이 - 원본 길이)
            offset += displayText.utf16.count - match.range.length
        }
        
        // AttributedString 생성 및 스타일 적용
        let mutableAttributedString = NSMutableAttributedString(string: resultText)
        
        let fullRange = NSRange(location: 0, length: resultText.utf16.count)
        mutableAttributedString.addAttributes([
            .foregroundColor: UIColor.gray02,
            .font: FontStyle.Body1.regular
        ], range: fullRange)
        
        for mentionInfo in mentionRanges {
            guard mentionInfo.range.location + mentionInfo.range.length <= mutableAttributedString.length else {
                continue
            }
            
            mutableAttributedString.addAttributes([
                .foregroundColor: UIColor.appPrimary,
                .font: FontStyle.Body1.medium,
                NSAttributedString.Key(rawValue: "MentionTag"): mentionInfo.id
            ], range: mentionInfo.range)
        }
        
        self.attributedText = mutableAttributedString
        resetTypingAttributes()
    }
    
    func handleSelectionConfirmed() {
        let selectedRange = selectedRange
        guard selectedRange.length == 0,
              let mentionRange = getMentionRange(at: selectedRange.location),
              selectedRange.location > mentionRange.location &&
                selectedRange.location < mentionRange.location + mentionRange.length else { return }

        let mentionEndPosition = mentionRange.location + mentionRange.length
        
        let hasSpaceAfterMention: Bool
        if mentionEndPosition < attributedText.length {
            let nextCharRange = NSRange(location: mentionEndPosition, length: 1)
            let nextCharacter = attributedText.attributedSubstring(from: nextCharRange).string
            hasSpaceAfterMention = nextCharacter == " "
        } else {
            hasSpaceAfterMention = false  // ✅ else 추가!
        }
        
        DispatchQueue.main.async {
            if !hasSpaceAfterMention {
                guard let attributedText = self.attributedText else { return }
                let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
                mutableAttributedText.insert(NSAttributedString(string: " "), at: mentionEndPosition)
                self.attributedText = mutableAttributedText
            }
            self.selectedRange = NSRange(location: mentionEndPosition + 1, length: 0)
            self.resetTypingAttributes()
        }
    }
}

