//
//  CommentSectionHeader.swift
//  Mople
//
//  Created by CatSlave on 8/4/25.
//

import UIKit
import SnapKit

final class CommentSectionHeader: UITableViewHeaderFooterView {
    
    // MARK: - UI Components
    private let countView: CountView = {
        let view = CountView()
        view.titleText = L10n.comment
        view.countText = L10n.itemCount(0)
        view.backgroundColor = .defaultWhite
        return view
    }()
    
    // MARK: - Life Cycle
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        self.contentView.addSubview(countView)
        self.contentView.backgroundColor = .defaultWhite
        
        countView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(28)
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(8)
        }
    }
    
    public func updateCount(_ count: Int) {
        countView.countText = L10n.itemCount(count)
    }
}
