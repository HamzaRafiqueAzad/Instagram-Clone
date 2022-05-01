//
//  IGFeedPostHeaderTableViewCell.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol IGFeedPostHeaderTableViewCellDelegate: AnyObject {
    func didTapMoreButton()
    func didTapUsername(with user: String)
}

class IGFeedPostHeaderTableViewCell: UITableViewCell {

    static let identifier = "IGFeedPostHeaderTableViewCell"
    weak var delegate: IGFeedPostHeaderTableViewCellDelegate?
    
    private let database = Firestore.firestore()
    
    private let profilePhotoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let usernameLabel: UILabel = {
       let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 18, weight: .medium)
        
        return label
    }()
    
    private let moreButton: UIButton = {
       let button = UIButton()
        button.tintColor = .label
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        return button
    }()
    
    @objc private func handleTap(_ sender: Any) {
        print("Ok")
        let userData: User
        database.collection("users").document(usernameLabel.text!).getDocument { [self] (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                let userData =  try! document.data(as: User.self)
                UsefulValues.otherUser = userData!
                delegate?.didTapUsername(with: userData!.username)
            } else {
                print("Document does not exist")
            }
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemBackground
        
        contentView.addSubview(profilePhotoImageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapGesture.numberOfTouchesRequired = 1
        tapGesture.numberOfTapsRequired = 1
        usernameLabel.isUserInteractionEnabled = true
        usernameLabel.addGestureRecognizer(tapGesture)
        
        moreButton.addTarget(self, action: #selector(didTapMore), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapMore() {
        delegate?.didTapMoreButton()
    }
    
    public func configure(with model: String) {
        // Configure the cell
        self.database.collection("users").document(model).getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    let userData =  try! document.data(as: User.self)
                    let user = userData!
                    self.usernameLabel.text = user.username
                    self.profilePhotoImageView.sd_setImage(with: user.profilePhoto)
                    print("User exists.")
                } else {
                    print("Document does not exist")
                }
            }

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let size = contentView.height - 4
        profilePhotoImageView.frame = CGRect(x: 2,
                                             y: 2,
                                             width: size,
                                             height: size)
        profilePhotoImageView.layer.cornerRadius = size / 2
        
        moreButton.frame = CGRect(x: contentView.width - size - 2,
                                  y: 2,
                                  width: size,
                                  height: size)
        
        usernameLabel.frame = CGRect(x: profilePhotoImageView.right+10,
                                     y: 2,
                                     width: contentView.width-(size*2) - 15,
                                     height: contentView.height - 4)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        profilePhotoImageView.image = nil
    }

}
