//
//  Models.swift
//  Instagram
//
//  Created by Hamza Rafique Azad on 13/4/22.
//

import Foundation

enum Gender: String, Codable {
    case male, female, other
}

struct User: Codable {
    let username: String
    let email: String
    let bio: String
    let name: String
    var profilePhoto: URL
    let birthDate: Date
    let gender: Gender
    var counts: UserCount
    let joinDate: Date
    var posts: [UserPost]
}

struct UsefulValues {
    static var user = User(username: "@hamma",
                           email: "hamza@gmail.com",
                           bio: "",
                           name: "",
                           profilePhoto: URL(string: "https://www.google.com")!,
                           birthDate: Date(),
                           gender: .male,
                           counts: UserCount(followersCount: 1,
                                             followingCount: 1,
                                             postsCount: 0),
                           joinDate: Date(),
                           posts: [UserPost]())
    
    static var otherUser = User(username: "@hamma",
                                email: "hamza@gmail.com",
                                bio: "",
                                name: "",
                                profilePhoto: URL(string: "https://upleap.com/blog/wp-content/uploads/2018/10/how-to-create-the-perfect-instagram-profile-picture.jpg")!,
                                birthDate: Date(),
                                gender: .male,
                                counts: UserCount(followersCount: 1,
                                                  followingCount: 1,
                                                  postsCount: 0),
                                joinDate: Date(),
                                posts: [UserPost]())
    
    static var allPosts = AllPosts(userPosts: [UserPost]())
}

struct AllPosts: Codable {
    var userPosts: [UserPost]
}

struct UserCount: Codable{
    let followersCount: Int
    let followingCount: Int
    var postsCount: Int
}

public enum UserPostType: String, Codable {
    case photo = "Photo"
    case video = "Video"
}

/// Represents a User Post
public struct UserPost: Codable, Equatable {
    public static func == (lhs: UserPost, rhs: UserPost) -> Bool {
        return lhs.postURL == rhs.postURL
    }
    
    let identifier: String
    let postType: UserPostType
    let thumbnailImage: URL
    let postURL: URL // Either video or full resolution photo URL
    let caption: String?
    let likeCount: [PostLike]
    let comments: [PostComment]
    let createdDate: Int64
    let taggedUsers: [String]
    let ownerUsername: String
}

struct PostLike: Codable {
    let username: String
    let postIdentifier: String
}

struct PostComment: Codable {
    let identifier: String
    let username: String
    let text: String
    let commentDate: Date
    let likes: [CommentLike]
}

struct CommentLike: Codable {
    let username: String
    let commentIdentifier: String
}
