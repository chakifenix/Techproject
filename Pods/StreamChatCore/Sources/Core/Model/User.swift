//
//  User.swift
//  StreamChatCore
//
//  Created by Alexey Bukhtin on 01/04/2019.
//  Copyright © 2019 Stream.io Inc. All rights reserved.
//

import Foundation

/// A user.
public struct User: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case avatarURL = "image"
        case role
        case online
        case created = "created_at"
        case updated = "updated_at"
        case lastActiveDate = "last_active"
        case mutedUsers = "mutes"
    }
    
    static let unknown = User(id: "", name: "")
    
    public enum Role: String, Codable {
        case user
        case admin
        case guest
    }
    
    /// A user id.
    public let id: String
    /// A user name.
    public let name: String
    /// An avatar URL.
    public let avatarURL: URL?
    /// A created date.
    public let created: Date
    /// An updated date.
    public let updated: Date
    /// A last active date.
    public let lastActiveDate: Date?
    /// An indicator if a user is online.
    public let online: Bool
    /// A user role.
    public let role: Role
    /// Muted users.
    public internal(set) var mutedUsers: [MutedUser]
    
    /// Check if the user is the current user.
    public var isCurrent: Bool {
        if let user = Client.shared.user {
            return self == user
        }
        
        return false
    }
    
    /// The current user.
    public static var current: User? {
        return Client.shared.user
    }
    
    /// Checks if the user can be muted.
    public var canBeMuted: Bool {
        return !isCurrent
    }
    
    /// Checks if the user is muted.
    public var isMuted: Bool {
        guard !isCurrent, let currentUser = User.current else {
            return false
        }
        
        return currentUser.mutedUsers.first(where: { $0.user == self }) != nil
    }
    
    /// Returns the user as a member.
    public var asMember: Member {
        return Member(self)
    }
    
    /// Init a user.
    ///
    /// - Parameters:
    ///     - id: a user id.
    ///     - name: a user name.
    ///     - an avatar URL.
    public init(id: String, name: String, avatarURL: URL? = nil) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        created = .default
        updated = .default
        lastActiveDate = .default
        online = false
        mutedUsers = []
        role = .user
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        created = try container.decode(Date.self, forKey: .created)
        updated = try container.decode(Date.self, forKey: .updated)
        lastActiveDate = try container.decodeIfPresent(Date.self, forKey: .lastActiveDate)
        online = try container.decode(Bool.self, forKey: .online)
        role = try container.decode(Role.self, forKey: .role)
        mutedUsers = try container.decodeIfPresent([MutedUser].self, forKey: .mutedUsers) ?? []
        
        if let name = try? container.decodeIfPresent(String.self, forKey: .name) {
            self.name = name
        } else {
            name = id
        }
        
        if let avatarURL = try? container.decodeIfPresent(URL.self, forKey: .avatarURL),
           !avatarURL.absoluteString.contains("random_svg") {
            self.avatarURL = avatarURL
        } else {
            avatarURL = nil
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(avatarURL, forKey: .avatarURL)
    }
}

extension User: Hashable {
    
    public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
