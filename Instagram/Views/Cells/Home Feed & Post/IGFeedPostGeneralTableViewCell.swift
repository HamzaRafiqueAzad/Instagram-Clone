//
//  IGFeedPostGeneralTableViewCell.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import UIKit


/// Comments
class IGFeedPostGeneralTableViewCell: UITableViewCell {

    static let identifier = "IGFeedPostGeneralTableViewCell"
    
    private let usernameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    
    private let commentLabel: UILabel = {
       let label = UILabel()
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(usernameLabel)
        contentView.addSubview(commentLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with model: PostComment) {
        // Configure the cell
        commentLabel.text = model.text
        usernameLabel.text = model.username
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = contentView.height - 4
        
        usernameLabel.frame = CGRect(x: 5,
                                     y: 2,
                                     width: contentView.width-(size*2) - 15,
                                     height: contentView.height - 4)
        
        commentLabel.frame = CGRect(x: usernameLabel.right - 200,
                                  y: 2,
                                    width: contentView.width - 5,
                                  height: size)
    }

}
