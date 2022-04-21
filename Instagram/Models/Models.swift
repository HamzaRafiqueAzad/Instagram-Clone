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
    let bio: String
    let name: String
    let profilePhoto: URL
    let birthDate: Date
    let gender: Gender
    var counts: UserCount
    let joinDate: Date
}

struct UsefulValues {
    static var user = User(username: "@hamma",
                           bio: "",
                           name: "",
                           profilePhoto: URL(string: "https://www.google.com")!,
                           birthDate: Date(),
                           gender: .male,
                           counts: UserCount(followers: 1,
                                             following: 1,
                                             posts: 1),
                           joinDate: Date())
}

struct UserCount: Codable{
    let followers: Int
    let following: Int
    var posts: Int
}

public enum UserPostType: String {
    case photo = "Photo"
    case video = "Video"
}

/// Represents a User Post
public struct UserPost {
    let identifier: String
    let postType: UserPostType
    let thumbnailImage: URL
    let postURL: URL // Either video or full resolution photo URL
    let caption: String?
    let likeCount: [PostLike]
    let comments: [PostComment]
    let createdDate: Date
    let taggedUsers: [String]
    let owner: User
}

struct PostLike {
    let username: String
    let postIdentifier: String
}

struct PostComment {
    let identifier: String
    let username: String
    let text: String
    let createdDate: Date
    let likes: [CommentLike]
}

struct CommentLike {
    let username: String
    let commentIdentifier: String
}
