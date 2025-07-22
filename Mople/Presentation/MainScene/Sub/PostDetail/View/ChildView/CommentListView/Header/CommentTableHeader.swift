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
        view.titleText = L10n.comment
        view.setMargin(inset: .init(top: 0, left: 20, bottom: 8, right: 20))
        view.backgroundColor = .defaultWhite
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
        self.contentView.addSubview(countView)
        
        countView.snp.makeConstraints { make in
            make.top.equalToSuperview().priority(.high)
            make.horizontalEdges.bottom.equalToSuperview().priority(.high)
        }
    }
    
    public func setCount(_ count: Int?) {
        guard let count else { return }
        countView.countText = L10n.itemCount(count)
    }
}
