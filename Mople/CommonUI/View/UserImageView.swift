//
//  participantImage.swift
//  Group
//
//  Created by CatSlave on 9/5/24.
//

import UIKit
import Kingfisher

final class UserImageView: UIImageView {
    
    // MARK: - Variables
    private var isSetRadius: Bool = false
    private var task: DownloadTask?
    
    // MARK: - LifeCycle
    init() {
        super.init(frame: .zero)
        defaultImage()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        task?.cancel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setRadius()
    }
    
    // MARK: - UI Setup
    private func setRadius() {
        guard !isSetRadius else { return }
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
        isSetRadius = true
    }
    
    private func defaultImage() {
        self.image = .defaultUser
        self.contentMode = .scaleAspectFill
    }
}

extension UserImageView {
    public func setImage(_ path: String?) {
        task = self.kfSetimage(path, defaultImageType: .user)
    }
    
    public func cancleImageLoad() {
        task?.cancel()
    }
    
    public func setLayer() {
        self.layer.makeLine(width: 1)
    }
}


