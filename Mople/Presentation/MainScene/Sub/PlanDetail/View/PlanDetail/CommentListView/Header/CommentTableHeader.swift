//
//  CommentTableHeader.swift
//  Mople
//
//  Created by CatSlave on 1/24/25.
//

import UIKit
import SnapKit

final class CommentTableHeader: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView()
        view.setBottomInset(8)
        view.backgroundColor = ColorStyle.Default.white
        return view
    }()

    // MARK: - LifeCycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        self.contentView.backgroundColor = ColorStyle.BG.secondary
        self.contentView.addSubview(countView)
        
        countView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(8).priority(.high)
            make.horizontalEdges.bottom.equalToSuperview().priority(.high)
        }
    }
    
    public func setTitle(_ title: String) {
        countView.titleText = title
    }
    
    public func setCount(_ count: Int?) {
        guard let count else { return }
        countView.countText = "\(count)개"
    }
}
