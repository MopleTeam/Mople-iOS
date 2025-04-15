//
//  participantImage.swift
//  Group
//
//  Created by CatSlave on 9/5/24.
//

import UIKit
import Kingfisher

final class ProfileView: UIImageView {
    
    // MARK: - Variables
    private var isSetRadius: Bool = false
    private var task: DownloadTask?
    
    // MARK: - LifeCycle
    init() {
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        task?.cancel()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        initialSetup()
    }
    
    // MARK: - UI Setup
    private func initialSetup() {
        guard !isSetRadius else { return }
        self.layer.cornerRadius = self.frame.height / 2
        isSetRadius = true
    }
    
    private func setupUI() {
        defaultImage()
        setLayer()
    }
    
    private func defaultImage() {
        self.image = .defaultIProfile
        self.contentMode = .scaleAspectFill
    }
    
    private func setLayer() {
        self.clipsToBounds = true
        self.layer.makeLine(width: 1)
    }
}

extension ProfileView {
    public func setImage(_ path: String?) {
        task = self.kfSetimage(path, defaultImageType: .user)
    }
    
    public func cancleImageLoad() {
        task?.cancel()
    }
}


