//
//  IGFeedPostTableViewCell.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import AVFoundation
import UIKit
import SDWebImage

/// Cell for primary post content
final class IGFeedPostTableViewCell: UITableViewCell {
    
    static let identifier = "IGFeedPostTableViewCell"
    
    private var player: AVPlayer?
    private var playerLayer = AVPlayerLayer()
    
    private let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = nil
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.addSublayer(playerLayer)
        contentView.addSubview(postImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with post: UserPost) {
        postImageView.sd_setImage(with: post.postURL)
        
        return
        
        // Configure the cell
        switch post.postType {
        case .photo:
            // Show Image
            postImageView.sd_setImage(with: post.postURL)
        case .video:
            // Load and play Video
            player = AVPlayer(url: post.postURL)
            playerLayer.player = player
            playerLayer.player?.volume = 0
            playerLayer.player?.play()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playerLayer.frame = contentView.bounds
        postImageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
    }
}
