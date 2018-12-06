//
//  User.swift
//  App
//
//  Created by Jacob Rhoda on 11/28/18.
//

import Vapor
import FluentMySQL
import Authentication

final class User: _MySQLModel {
    typealias ID = Int

    var userID: Int?
    var username: String
    var email: String

    var sessionID: String?
    var passwordHash: String
    
    static var idKey: IDKey = \.userID

    /// Creates a new ``.
    init(userID: ID?, username: String, email: String, password: String) throws {
        self.userID = userID
        self.username = username
        self.email = email
        self.passwordHash = try BCrypt.hash(password)
    }
}

extension User: SessionAuthenticatable {
    static func authenticate(sessionID: SessionID, on connection: DatabaseConnectable) -> EventLoopFuture<User?> {
        return User.query(on: connection)
            .filter(\.sessionID, .equal, sessionID)
            .first()
    }
}

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> = \.username
    static var passwordKey: WritableKeyPath<User, String> = \.passwordHash
}
