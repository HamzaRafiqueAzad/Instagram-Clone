//
//  PublishPostViewController.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import UIKit
import FirebaseStorage
import FirebaseFirestore
import FirebaseFirestoreSwift

class PublishPostViewController: UIViewController {
    
    private let storage = Storage.storage().reference()
    
    private let database = Firestore.firestore()
    
    let center = HomeViewController.notificationCenter
    
    var userPostImage = UIImage()
    
    
    private let caption: UITextView = {
       let textField = UITextView()
        textField.text = "Enter caption..."
        textField.textColor = UIColor.lightGray
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 10
        textField.layer.borderWidth = 1
        textField.textAlignment = .left
        textField.translatesAutoresizingMaskIntoConstraints = true
        textField.sizeToFit()
        
        return textField
    }()
    
    public let userPostImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .red
        imageView.layer.masksToBounds = true
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        // Do any additional setup after loading the view.
        userPostImageView.image = userPostImage
        view.addSubview(userPostImageView)
        caption.delegate = self
        view.addSubview(caption)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: .done, target: self, action: #selector(didTapPublish))
    }
    
    @objc private func didTapPublish() {
        
        guard let data = userPostImage.pngData() else {  return }
        
        
        
        DispatchQueue.main.async {
            print("USername: \(UsefulValues.user.username)")
            let uploadTask = self.storage.child("\(UsefulValues.user.username)/\(UsefulValues.user.counts.postsCount+1).png").putData(data, metadata: nil) { metadata, error in
                guard let metadata = metadata else {
                    print("Failed to upload because: \(error?.localizedDescription)")
                    return
                }
                
                print("Photo Uploaded.")
                
                do {
                    UsefulValues.user.counts.postsCount += 1
                    let user = try PropertyListEncoder().encode(UsefulValues.user)
                    UserDefaults.standard.setValue(user, forKey: "user")
                } catch {
                    
                }
                
                self.storage.child("\(UsefulValues.user.username)/\(UsefulValues.user.counts.postsCount).png").downloadURL { url, error in
                    guard let url = url, error == nil else {
                        return
                    }
                    
                    let urlString = url.absoluteString
                    print("Url: \(urlString)")
                    do {
                        var post = UserPost(identifier: "", postType: .photo, thumbnailImage: URL(string: "https://icon-library.com/images/loading-icon-transparent-background/loading-icon-transparent-background-25.jpg")!, postURL: url, caption: "", likeCount: [PostLike(username: "hamza", postIdentifier: "")], comments: [PostComment(identifier: "", username: "hamza", text: "Good one", commentDate: Date(), likes: [CommentLike(username: "hamza", commentIdentifier: "")])], createdDate: Date().millisecondsSince1970, taggedUsers: [""], ownerUsername: UsefulValues.user.username)
                        UsefulValues.user.posts.append(post)
                        print("Posting....")
                        try self.database.collection("users").document(UsefulValues.user.username).collection("userPosts").addDocument(from: post)
                        self.database.collection("users").document(UsefulValues.user.username).updateData([
                            "counts.postsCount" : UsefulValues.user.counts.postsCount,
                        ])
                        print(UsefulValues.user.posts.count)
                        print("POSTED....")
                        UsefulValues.allPosts.userPosts = []
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
                                    try post = document.data(as: UserPost.self)!
                                            UsefulValues.allPosts.userPosts.append(post)
                                        print("-------------------------------------")
                                        print(post)
                                        print("-------------------------------------")
                                    } catch {
                                        
                                    }
                                    print("Post: \(post)")
                                }

                                print("Count = \(count)");
                            }
                        }
                    } catch {
                        print(error.localizedDescription)
                    }
                    
                    let alert = UIAlertController(title: "Published", message: "Your post has been successfully published.", preferredStyle: .alert)
                    UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                            alert.dismiss(animated: true, completion: nil)
                        }
                }
            }
            let observer = uploadTask.observe(.progress) { snapshot in
              // A progress event occured
                self.center.removeAllDeliveredNotifications()
                let completed = Float(snapshot.progress!.completedUnitCount)
                let percentage = Int(completed/Float(data.count)*100)
                print(Int(completed/Float(data.count)*100))
                let content = UNMutableNotificationContent()
                content.title = "Uploading"
                content.body = "Progress: \(percentage)%"
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.000000000000000000000000001, repeats: false)
                
                let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                
                self.center.add(request) { error in
                    if error != nil {
                        print(error?.localizedDescription)
                    }
                }
                
            }
        }
        navigationController?.popToRootViewController(animated: true)
    }
    

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let userPostPhotoSize = view.width / 4

        userPostImageView.frame = CGRect(x: 5,
                                             y: view.top + 100,
                                             width: userPostPhotoSize,
                                             height: caption.contentSize.height + 100).integral
        
        caption.frame = CGRect(x: userPostImageView.right + 5, y: view.top + 100, width: view.width - 15 - userPostPhotoSize, height: caption.contentSize.height + 20)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PublishPostViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = .label
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Caption"
            textView.textColor = UIColor.lightGray
        }
    }
}


extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }
}
