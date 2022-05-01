//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import Darwin
import Foundation

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Firestore.firestore()
    
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
        
        let user = User(username: "\(username)", email: email,
                        bio: "This is the first account",
                        name: "Hamza Rafique Azad",
                        profilePhoto: URL(string: "https://upleap.com/blog/wp-content/uploads/2018/10/how-to-create-the-perfect-instagram-profile-picture.jpg")!,
                        birthDate: Date(),
                        gender: .male,
                        counts: UserCount(followersCount: 1,
                                          followingCount: 1,
                                          postsCount: 0),
                        joinDate: Date(), posts: [UserPost]())
        UsefulValues.user = user
        
        UserDefaults.standard.set(username, forKey: "username")
        
        do {
            try database.collection("users").document(username).setData(from: user)
            try database.collection("users").document(username).setData(["email" : email], merge: true)
        } catch {
            
        }
    }
}
