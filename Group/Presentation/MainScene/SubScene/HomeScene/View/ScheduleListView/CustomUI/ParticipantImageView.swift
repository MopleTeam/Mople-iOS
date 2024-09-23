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
        guard let path = path else { return }
        let imageUrl = URL(string: path)
        task = self.kf.setImage(
            with: imageUrl,
            placeholder: AppDesign.Profile.defaultImage,
            options: [.transition(.fade(0.2))]
        )
    }
    
    deinit {
        task?.cancel()
    }
    
    private func setupUI() {
        defaultImage()
        setLayer()
    }
    
    private func defaultImage() {
        self.image = AppDesign.Profile.defaultImage
        self.contentMode = .scaleAspectFill
    }
    
    private func setLayer() {
        self.clipsToBounds = true
        
        self.layer.borderWidth = 2
        self.layer.borderColor = AppDesign.defaultWihte.cgColor
    }
}
