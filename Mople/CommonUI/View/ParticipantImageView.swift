//
//  participantImage.swift
//  Group
//
//  Created by CatSlave on 9/5/24.
//

import UIKit
import Kingfisher

final class ParticipantImageView: UIImageView {
    
    private var task: DownloadTask?
    
    init(imagePath: String?) {
        super.init(frame: .zero)
        
        self.setupUI()
        self.setImage(imagePath)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    private func setImage(_ path: String?) {
        task = self.kfSetimage(path, defaultImageType: .user)
    }
    
    deinit {
        task?.cancel()
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
        self.layer.makeLine(width: 2)
    }
}
