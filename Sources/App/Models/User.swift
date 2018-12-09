//
//  User.swift
//  App
//
//  Created by Jacob Rhoda on 11/28/18.
//

import Vapor
import FluentMySQL
import Authentication

enum UserType: Int, CaseIterable, MySQLEnumType {
    case driver
    case administrator
}

final class User: _MySQLModel {
    typealias ID = Int

    var userID: Int?
    var username: String
    var email: String
    var passwordHash: String
    var type: UserType

    static var idKey: IDKey = \.userID

    /// Creates a new ``.
    init(userID: ID?, username: String, email: String, password: String, type: UserType = .driver) throws {
        self.userID = userID
        self.username = username
        self.email = email
        self.passwordHash = try BCrypt.hash(password)
        self.type = type
    }
}

extension User: SessionAuthenticatable { }

extension User: PasswordAuthenticatable {
    static var usernameKey: WritableKeyPath<User, String> = \.username
    static var passwordKey: WritableKeyPath<User, String> = \.passwordHash

    public static func authenticate(username: String, password: String, on conn: DatabaseConnectable) -> NIO.EventLoopFuture<User?> {
        return User.authenticate(username: username, password: password, using: BCryptDigest(), on: conn)
    }
}
