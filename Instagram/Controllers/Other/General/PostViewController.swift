//
//  PostViewController.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

/// States of a rendered cell
enum PostRenderType {
    case header(provider: String)
    case primaryContent(provider: UserPost) // Post
    case actions(provider: String) // like, comment, share
    case comments(comments: [PostComment])
}

/// Model of a rendered cell
struct PostRenderViewModel {
    let renderType: PostRenderType
}

class PostViewController: UIViewController {
    
    private let model: UserPost?
    
    private let database = Firestore.firestore()
    
    private var renderModels = [PostRenderViewModel]()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        
        // Register cells
        tableView.register(IGFeedPostTableViewCell.self,
                           forCellReuseIdentifier: IGFeedPostTableViewCell.identifier)
        tableView.register(IGFeedPostHeaderTableViewCell.self,
                           forCellReuseIdentifier: IGFeedPostHeaderTableViewCell.identifier)
        tableView.register(IGFeedPostActionsTableViewCell.self,
                           forCellReuseIdentifier: IGFeedPostActionsTableViewCell.identifier)
        tableView.register(IGFeedPostGeneralTableViewCell.self,
                           forCellReuseIdentifier: IGFeedPostGeneralTableViewCell.identifier)
        
        return tableView
    }()
    
    init(model: UserPost?) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        configureModels()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureModels() {
        print(self.model)
        guard let userPostModel = self.model else { return }
        
        print(userPostModel.createdDate)
        
        // - Header Model
        renderModels.append(PostRenderViewModel(renderType: .header(provider: userPostModel.ownerUsername)))
        
        // - Post Cell Model
        renderModels.append(PostRenderViewModel(renderType: .primaryContent(provider: userPostModel)))
        
        // - Action Buttons Cell Model
        renderModels.append(PostRenderViewModel(renderType: .actions(provider: "")))
        
        // - n Number of General Models for comments
        var comments = [PostComment]()
        comments.append(PostComment(identifier: "123",
                                    username: "@hamza",
                                    text: "Great Post",
                                    commentDate: Date(),
                                    likes: []))
        comments.append(PostComment(identifier: "123",
                                    username: "@hamma",
                                    text: "Great Post",
                                    commentDate: Date(),
                                    likes: []))
        comments.append(PostComment(identifier: "123",
                                    username: "@kanye",
                                    text: "Great Post",
                                    commentDate: Date(),
                                    likes: []))
        comments.append(PostComment(identifier: "123",
                                    username: "@drake",
                                    text: "Great Post",
                                    commentDate: Date(),
                                    likes: []))
        
        renderModels.append(PostRenderViewModel(renderType: .comments(comments: comments)))
        
    }
    
    // - Header Model
    // - Post Cell Model
    // - Action Buttons Cell Model
    // - n Number of General Models for comments
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
}

extension PostViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        print(renderModels.count)
        return renderModels.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch renderModels[section].renderType {
        case .actions(_): return 1
        case .comments(let comments): return comments.count > 4 ? 4 : comments.count
        case .primaryContent(_): return 1
        case .header(_): return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = renderModels[indexPath.section]
        
        switch model.renderType {
        case .actions(let actions):
            let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostActionsTableViewCell.identifier,
                                                     for: indexPath) as! IGFeedPostActionsTableViewCell
            return cell
            
        case .comments(let comments):
            let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostGeneralTableViewCell.identifier,
                                                     for: indexPath) as! IGFeedPostGeneralTableViewCell
            cell.configure(with: comments[indexPath.row])
            return cell
            
        case .primaryContent(let post):
            let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostTableViewCell.identifier,
                                                     for: indexPath) as! IGFeedPostTableViewCell
            cell.configure(with: post)
            return cell
            
        case .header(let user):
            let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostHeaderTableViewCell.identifier,
                                                     for: indexPath) as! IGFeedPostHeaderTableViewCell
            cell.configure(with: user)
            cell.delegate = self
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = renderModels[indexPath.section]
        
        switch model.renderType {
        case .actions(_): return 60
        case .comments(_): return 50
        case .primaryContent(_): return tableView.width
        case .header(_): return 70
            
        }
    }
    
    
}

extension PostViewController: IGFeedPostHeaderTableViewCellDelegate {
    
    func didTapUsername(with user: String) {
        let vc = OtherProfileViewController()
        print("Okay")
//        let otherName = user.username
        self.database.collection("users").document(user).getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    let userData =  try! document.data(as: User.self)
                    UsefulValues.otherUser = userData!
                    vc.title = UsefulValues.otherUser.username
                    self.navigationController?.pushViewController(vc, animated: true)
                    
                } else {
                    print("Document does not exist")
                }
            }
    }
    
    func didTapMoreButton() {
        let actionSheet = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete Post", style: .destructive, handler: { [weak self] _ in
            self!.database.collection("users").document(UsefulValues.user.username).collection("userPosts").getDocuments()
            {
                (querySnapshot, err) in

                if let err = err
                {
                    print("Error getting documents: \(err)");
                }
                else
                {
                    for document in querySnapshot!.documents {
                        print("Doc: \(document)")
                        do {
                            let post = try document.data(as: UserPost.self)!
                            if post == self?.model {
                                self!.database.collection("users").document(UsefulValues.user.username).collection("userPosts").document("\(document.documentID)").delete()
                            }
                        } catch {
                            
                        }
                    }
                }
            }
            if let index = UsefulValues.allPosts.userPosts.firstIndex(of: (self?.model)!) {
                UsefulValues.allPosts.userPosts.remove(at: index) // array is now ["world", "hello"]
                UsefulValues.user.counts.postsCount -= 1
                do {
                    try self!.database.collection("users").document(UsefulValues.user.username).setData(from: UsefulValues.user)
                    self!.navigationController?.popToRootViewController(animated: true)
                } catch {
                    
                }
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
}
