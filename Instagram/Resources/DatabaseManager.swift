//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import FirebaseDatabase
import FirebaseAuth
import Darwin
import Foundation

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    // MARK: - Public
    
    /// Check if username and email is available
    /// - Parameters
    ///     - email: String representing email
    ///     - username: String representing username
    public func canCreateNewUser(with email: String, username: String, completion: (Bool) -> Void) {
        completion(true)
    }
    
    /// Inserts new user data to database
    /// - Parameters
    ///     - email: String representing email
    ///     - username: String representing username
    ///     - completion: Async callback for result if database entry succeeded
    public func insertNewUser(with email: String, username: String, completion: @escaping (Bool) -> Void) {
        
//        guard let userID = Auth.auth().currentUser?.uid else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy HH:mm"
        let user = User(username: "\(username)",
                        bio: "This is the first account",
                        name: "Hamza Rafique Azad",
                        profilePhoto: URL(string: "https://upleap.com/blog/wp-content/uploads/2018/10/how-to-create-the-perfect-instagram-profile-picture.jpg")!,
                        birthDate: Date(),
                        gender: .male,
                        counts: UserCount(followers: 1,
                                          following: 1,
                                          posts: 1),
                        joinDate: Date())
        UsefulValues.user = user
        
        UserDefaults.standard.set(username, forKey: "username")
        
        database.child(username).updateChildValues(["email" : email]) { error, _ in
            if error ==  nil {
                // Succeeded
                completion(true)
                return
            } else {
                // Failed
                completion(false)
                return
            }
        }
        
        print("\(user.gender)")
        
        let userData = ["username" : user.username, "bio" : user.bio, "name" : user.name, "profilePhoto" : user.profilePhoto.absoluteString, "birthDate" : formatter.string(from: user.birthDate), "gender" : "\(user.gender)", "followers" : user.counts.followers, "following" : user.counts.following, "posts" : user.counts.posts, "joinDate" : formatter.string(from: user.joinDate)] as [String: Any]
        
        database.child(username).updateChildValues(userData) { error, _ in
            if error ==  nil {
                // Succeeded
                print("USER ADDED")
                completion(true)
                return
            } else {
                // Failed
                completion(false)
                return
            }
        }
        
//        database.child(email.safeDatabaseKey()).setValue(["username": username]) { error, _ in
//            if error ==  nil {
//                // Succeeded
//                completion(true)
//                return
//            } else {
//                // Failed
//                completion(false)
//                return
//            }
//        }
        
    }
}
