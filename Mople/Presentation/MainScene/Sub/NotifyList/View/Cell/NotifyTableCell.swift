//
//  NotifyTableCell.swift
//  Mople
//
//  Created by CatSlave on 4/10/25.
//

import UIKit
import SnapKit
import Kingfisher

final class NotifyTableCell: UITableViewCell {
    
    // MARK: - Variables
    private var task: DownloadTask?
    private var defaultColor: UIColor?
    
    // MARK: - UI Components
    private let thumbnailView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.makeLine(width: 1)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Title3.regular
        label.textColor = .text01
        label.numberOfLines = 2
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.font = FontStyle.Body2.medium
        label.textColor = .text03
        return label
    }()
    
    private lazy var titleStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        sv.axis = .vertical
        sv.spacing = 4
        sv.alignment = .fill
        sv.distribution = .fill
        return sv
    }()
    
    private lazy var mainStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [thumbnailView, titleStackView])
        sv.axis = .horizontal
        sv.spacing = 16
        sv.alignment = .center
        sv.distribution = .fill
        return sv
    }()
    
    // MARK: - LifeCycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task = nil
    }
    
    // MARK: - Highlight
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        print(#function, #line, "Path : # 하이라이트 ")
        let color = highlighted ? .bgSecondary : defaultColor
        contentView.backgroundColor = color
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.addSubview(mainStackView)
        
        mainStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(20)
        }
        
        thumbnailView.snp.makeConstraints { make in
            make.size.equalTo(40)
        }
    }
    
    public func configure(viewModel: NotifyViewModel) {
        task = thumbnailView.kfSetimage(viewModel.thumbnailPath,
                                        defaultImageType: .meet)
        highlightMessage(text: viewModel.title)
        
        subTitleLabel.text = viewModel.subTitle
        defaultColor = viewModel.isRead ? .clear : .bgInput
        contentView.backgroundColor = defaultColor
    }
    
    private func highlightMessage(text: String?) {
        guard let text else { return }

        let pattern = "<highlight>(.*?)</highlight>"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return }

        // 매칭된 highlight 텍스트 추출
        guard let match = regex.firstMatch(in: text, range: NSRange(location: 0, length: text.utf16.count)) else {
            titleLabel.text = text   // 태그 없으면 그냥 출력
            return
        }

        let highlightRangeInOriginal = match.range(at: 1) // ()안 그룹만

        // 1. clean text 만들기 (태그 제거)
        let cleanText = text
            .replacingOccurrences(of: "<highlight>", with: "")
            .replacingOccurrences(of: "</highlight>", with: "")

        // 2. cleanText 기준 Range 재계산
        let beforeHighlight = (text as NSString).substring(to: highlightRangeInOriginal.location)
            .replacingOccurrences(of: "<highlight>", with: "")
            .replacingOccurrences(of: "</highlight>", with: "")

        let startIndex = beforeHighlight.utf16.count         // clean 기준 start 위치
        let highlightLength = highlightRangeInOriginal.length // 길이는 동일

        let highlightRangeClean = NSRange(location: startIndex, length: highlightLength)

        // 3. AttributedText 적용
        let attributed = NSMutableAttributedString(string: cleanText)
        attributed.addAttributes([.font: FontStyle.Title3.regular], range: NSRange(location: 0, length: cleanText.utf16.count))
        attributed.addAttributes([.font: FontStyle.Title3.semiBold], range: highlightRangeClean)

        titleLabel.attributedText = attributed
    }
}

