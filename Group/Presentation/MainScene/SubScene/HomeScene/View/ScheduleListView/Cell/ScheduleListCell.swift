//
//  ScheduleListCell.swift
//  Group
//
//  Created by CatSlave on 9/3/24.
//

import UIKit
import SnapKit

final class ScheduleListCell: UICollectionViewCell {

    private var eventView: EventView = .init(type: .detail)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setRadius()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        self.contentView.backgroundColor = .white
        self.contentView.addSubview(eventView)

        eventView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setRadius() {
        self.contentView.clipsToBounds = true
        self.contentView.layer.cornerRadius = 12
    }

    public func configure(viewModel: ScheduleListItemViewModel) {
        self.eventView.configure(viewModel)
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

@available(iOS 13, *)
struct HeaderView_Preview: PreviewProvider {
    static var previews: some View {
        HomeViewController(reactor: ScheduleViewReactor(fetchUseCase: fetchRecentScheduleMock(), logOutAction: LogOutAction(logOut: {
            
        }))).showPreview()
    }
}
#endif




