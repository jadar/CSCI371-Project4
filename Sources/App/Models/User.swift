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

enum UserConfig {
    case driver(Driver.ID)
    case administrator

    var type: UserType {
        switch self {
        case .administrator: return .administrator
        case .driver: return .driver
        }
    }
}

final class User: _MySQLModel {
    typealias ID = Int

    var userID: Int?
    var username: String
    var email: String
    var passwordHash: String
    var type: UserType
    var driverID: Driver.ID?

    static var idKey: IDKey = \.userID

    var driver: Parent<User, Driver>? {
        return parent(\.driverID)
    }

    /// Creates a new ``.
    init(userID: ID?, username: String, email: String, password: String, type: UserConfig) throws {
        self.userID = userID
        self.username = username
        self.email = email
        self.passwordHash = try BCrypt.hash(password)

        switch type {
        case .driver(let driverID):
            self.type = .driver
            self.driverID = driverID
        case .administrator:
            self.type = .administrator
        }
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
