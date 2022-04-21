//
//  AuthManager.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 9/4/22.
//

import FirebaseAuth
import FirebaseDatabase
import UIKit

public class AuthManager {
    
    static let shared = AuthManager()
    
    private let database = Database.database().reference()
    
    // MARK: - Public
    
    public func registerNewUser(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        
        // Check if username is available
        // Check if email is available
        DatabaseManager.shared.canCreateNewUser(with: email, username: username) { canCreate in
            if canCreate {
                // Create Account
                Auth.auth().createUser(withEmail: email, password: password) { authResults, error in
                    guard error == nil, authResults != nil else {
                        // Firebase auth could not create account
                        completion(false)
                        return
                    }
                    
                    // Insert account into database
                    DatabaseManager.shared.insertNewUser(with: email, username: username) { inserted in
                        if inserted {
                            completion(true)
                            return
                        } else {
                            // Failed to insert to database
                            completion(false)
                            return
                        }
                    }
                    
                }
            } else {
                completion(false)
            }
        }
        
        
    }
    
    public func loginUser(username: String?, email: String?, password: String, completion: @escaping (Bool) -> Void) {
        
        if let email = email {
            // Email Login
            Auth.auth().signIn(withEmail: email, password: password) { authResults, error in
                guard authResults != nil, error == nil else {
                    completion(false)
                    return  
                }
                completion(true)
            }
            
        } else if let username = username {
            // Username Login
            print("USERNAME: \(username)")
            database.child(username).child("email").getData { error, snapshot in
                guard error == nil else {
                    print(error!.localizedDescription)
                    return;
                  }
                let email = snapshot.value as? String ?? "Unknown"
                print(email)
                
                Auth.auth().signIn(withEmail: email, password: password) { authResults, error in
                    guard authResults != nil, error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
                
            }
            
        }
        
    }
    
    /// Attempt to Log out Firebase User
    public func logOutUser(completion: (Bool) -> Void) {
        do{
            try Auth.auth().signOut()
            completion(true)
            return
        } catch {
            print(error)
            completion(false)
            return
        }
    }
    
}
