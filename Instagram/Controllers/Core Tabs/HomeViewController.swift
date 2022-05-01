//
//  ViewController.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import AVFoundation

struct HomeFeedRenderViewModel {
    let header: PostRenderViewModel
    let post: PostRenderViewModel
    let actions: PostRenderViewModel
    let comments: PostRenderViewModel
}

class HomeViewController: UIViewController {

    // 2. Get the shared instance of UNUserNotificationCenter
    static let notificationCenter = UNUserNotificationCenter.current()

    
    func requestAuthorizationForNotifications() async throws -> Bool {
        // 3. Define the types of authorization you need
        let authorizationOptions: UNAuthorizationOptions = [.alert, .sound, .badge]

        do {
            // 4. Request authorization to the user
            let authorizationGranted = try await HomeViewController.notificationCenter.requestAuthorization(options: authorizationOptions)
            // 5. Return the result of the authorization process
            return authorizationGranted
        } catch {
            throw error
        }
    }
    
    private var feedRenderModels = [HomeFeedRenderViewModel]()
    
    private let database = Firestore.firestore()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        async {
            do {
                let _ = try await requestAuthorizationForNotifications()
                HomeViewController.notificationCenter.delegate = self
            } catch {
                print(error.localizedDescription)
            }
        }
//        createMockModels()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
//        print("COUNTTTTT")
//        print(feedRenderModels.count)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        feedRenderModels = []
        createMockModels()
    }
    
    private func createMockModels() {
        do {
            try self.database.collection("users").getDocuments()
        {
            (querySnapshot, err) in
            if let err = err
            {
                print("Error getting documents: \(err)");
            } else {
                do {
                    for document in querySnapshot!.documents {
                        do {
                            try self.database.collection("users").document(document.documentID).collection("userPosts").order(by: "createdDate",descending: true).getDocuments(completion: { (snapshot, error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    do {
                                    for docs in snapshot!.documents {
                                        let post = try docs.data(as: UserPost.self)!
//                                        print("POST: \(post)")
                                        let viewModel = HomeFeedRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: document.documentID)), post: PostRenderViewModel(renderType: .primaryContent(provider: post)), actions: PostRenderViewModel(renderType: .actions(provider: "")), comments: PostRenderViewModel(renderType: .comments(comments: [PostComment]())))
//                                        print(viewModel)
                                        self.feedRenderModels.append(viewModel)
                                        self.tableView.reloadData()
                                        print("COUNT: \(self.feedRenderModels.count)")
                                    }
                                    } catch {
                                        
                                    }
                                }
                            })
                        } catch {
                            
                        }
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        } catch {
            
        }
        tableView.reloadData()
        let user = User(username: "hamza2", email: "hamza2@gmail.com",
                        bio: "",
                        name: "",
                        profilePhoto: URL(string: "https://www.google.com")!,
                        birthDate: Date(),
                        gender: .male,
                        counts: UserCount(followersCount: 1,
                                          followingCount: 1,
                                          postsCount: 1),
                        joinDate: Date(), posts: [UserPost]())
        
        let post = UserPost(identifier: "",
                            postType: .photo,
                            thumbnailImage: URL(string: "https://www.google.com")!,
                            postURL: URL(string: "https://www.google.com")!,
                            caption: nil,
                            likeCount: [],
                            comments: [],
                            createdDate: Date().millisecondsSince1970,
                            taggedUsers: [],
                            ownerUsername: user.username)
        
        var comments = [PostComment]()
        for x in 0..<2 {
            comments.append(PostComment(identifier: "456_\(x)",
                                        username: "@yaini",
                                        text: "This is the best post I've ever seen.",
                                        commentDate: Date(),
                                        likes: []))
        }
        
//        for x in 0..<5 {
//            let viewModel = HomeFeedRenderViewModel(header: PostRenderViewModel(renderType: .header(provider: user.username)), post: PostRenderViewModel(renderType: .primaryContent(provider: post)), actions: PostRenderViewModel(renderType: .actions(provider: "")), comments: PostRenderViewModel(renderType: .comments(comments: comments)))
//            feedRenderModels.append(viewModel)
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Check Auth Status
        loadUserData()
        handelNotAuthenticated()
    }
    
    private func loadUserData() {
        
        guard let data = UserDefaults.standard.value(forKey: "user") as? Data else {
            do {
                try Auth.auth().signOut()
            } catch {
                
            }
            return
        }
        do {
            UsefulValues.user = try PropertyListDecoder().decode(User.self, from: data)
            print("User Data Loaded From UserDefaults.")
        } catch {

        }
        
        try self.database.collection("users").document(UsefulValues.user.username).collection("userPosts").order(by: "createdDate", descending: true).getDocuments()
        {
            (querySnapshot, err) in

            if let err = err
            {
                print("Error getting documents: \(err)");
            }
            else
            {
                var count = 0
                for document in querySnapshot!.documents {
                    count += 1
                    print("Doc: \(document)")
                    do {
                        let post = try document.data(as: UserPost.self)!
                        if !(UsefulValues.allPosts.userPosts.contains(post)) {
                            UsefulValues.allPosts.userPosts.append(post)
                        }
                    } catch {
                        
                    }
                }

                print("Count = \(count)");
            }
        }
        
        database.collection("users").document(UsefulValues.user.username).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data().map(String.init(describing:)) ?? "nil"
                let userData =  try! document.data(as: User.self)
                UsefulValues.user = userData!
                do {
                let user = try PropertyListEncoder().encode(UsefulValues.user)
                UserDefaults.standard.set(user, forKey: "user")
                } catch {
                    
                }
                
            } else {
                print("Document does not exist")
            }
        }
        
    }
    
    private func handelNotAuthenticated() {
        
        if Auth.auth().currentUser == nil {
            //Show Login View
            let loginVC = LoginViewController()
            loginVC.modalPresentationStyle = .fullScreen
            present(loginVC, animated: true)
        } else {
        }
        
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return feedRenderModels.count * 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let x = section
        let model: HomeFeedRenderViewModel
        if x == 0 {
            model = feedRenderModels[0]
        } else {
            let position = x % 4 == 0 ? x / 4 : (x - (x % 4)) / 4
            model = feedRenderModels[position]
        }
        
        let subSection = x % 4
        
        if subSection == 0 {
            // Header
            return 1
        } else if subSection == 1 {
            // Post
            return 1
        } else if subSection == 2 {
            // Actions
            return 1
        } else if subSection == 3 {
            // Comments
            let commentsModel = model.comments
            switch commentsModel.renderType {
            case .comments(comments: let comments): return comments.count > 2 ? 2 : comments.count
            case .header, .actions, .primaryContent: return 0
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let x = indexPath.section
        let model: HomeFeedRenderViewModel
        if x == 0 {
            model = feedRenderModels[0]
        } else {
            let position = x % 4 == 0 ? x / 4 : (x - (x % 4)) / 4
            model = feedRenderModels[position]
        }
        
        let subSection = x % 4
        
        if subSection == 0 {
            // Header
            switch model.header.renderType {
            case .header(let user):
                let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostHeaderTableViewCell.identifier,
                                                         for: indexPath) as! IGFeedPostHeaderTableViewCell
                
                cell.configure(with: user)
                cell.delegate = self
                
                return cell
            case .comments, .actions, .primaryContent: return UITableViewCell()
            }
        } else if subSection == 1 {
            // Post
            switch model.post.renderType {
            case .primaryContent(let post):
                let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostTableViewCell.identifier,
                                                         for: indexPath) as! IGFeedPostTableViewCell
                
                cell.configure(with: post)
                
                return cell
            case .header, .actions, .comments: return UITableViewCell()
            }
        } else if subSection == 2 {
            // Actions
            switch model.actions.renderType {
            case .actions(let provider):
                let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostActionsTableViewCell.identifier,
                                                         for: indexPath) as! IGFeedPostActionsTableViewCell
                
                cell.delegate = self
                
                return cell
            case .header, .comments, .primaryContent: return UITableViewCell()
            }
        } else if subSection == 3 {
            // Comments
            switch model.comments.renderType {
            case .comments(let comments):
                let cell = tableView.dequeueReusableCell(withIdentifier: IGFeedPostGeneralTableViewCell.identifier,
                                                         for: indexPath) as! IGFeedPostGeneralTableViewCell
                return cell
            case .header, .actions, .primaryContent: return UITableViewCell()
            }
        }
        
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let subSection = indexPath.section % 4
        
        if subSection == 0 {
            // Header
            return 70
        } else if subSection == 1 {
            // Post
            return tableView.width
        } else if subSection == 2 {
            // Actions (Like/Comment)
            return 60
        } else if subSection == 3 {
            // Comment row
            return 50
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let subSection = section % 4
        return subSection == 3 ? 70 : 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    
}

extension HomeViewController: IGFeedPostHeaderTableViewCellDelegate {
    func didTapUsername(with user: String) {
        let vc = OtherProfileViewController()
//        print(user)
//        let otherName = user.username
        self.database.collection("users").document(user).getDocument { (document, error) in
                if let document = document, document.exists {
                    
                    let userData =  try! document.data(as: User.self)
                    UsefulValues.user = userData!
                    vc.title = UsefulValues.user.username
                    do {
                        try self.database.collection("users").document(UsefulValues.user.username).collection("userPosts").order(by: "createdDate", descending: true).getDocuments()
                    {
                        (querySnapshot, err) in
                        print(querySnapshot)
                        if let err = err
                        {
                            print("Error getting documents: \(err)");
                        } else {
                            do {
                                for document in querySnapshot!.documents {
                                let post = try document.data(as: UserPost.self)!
                                print("-------------------------------")
                                print(post)
                                print("-------------------------------")
                                if !(vc.userPosts.contains(post)) {
                                    vc.userPosts.append(post)
                                }
                                }
                                self.navigationController?.pushViewController(vc, animated: true)
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    }
                    } catch {
                        
                    }
                    
                    print("Document data: \(userData)")
                } else {
                    print("Document does not exist")
                }
            }
    }
    
    func didTapMoreButton() {
        let actionSheet = UIAlertController(title: "Post Options", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive, handler: { [weak self] _ in
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
}

extension HomeViewController: IGFeedPostActionsTableViewCellDelegate {
    func didTapLikeButton() {
        print("Like")
    }
    
    func didTapCommentButton() {
        print("Comment")
    }
    
    func didTapSendButton() {
        print("Send")
    }
}

extension HomeViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        if #available(iOS 14.0, *) {
            completionHandler([.alert, .sound, .banner])
        } else {
            // Fallback on earlier versions
            completionHandler([.alert, .sound, .badge])
        }
    }
    
    
    
}

