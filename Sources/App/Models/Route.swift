//
//  Route.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class Route: _MySQLModel {
    typealias ID = String

    var routeid: ID?
    var routename: String

    static var idKey: IDKey = \.routeid

    /// Creates a new ``.
    init(routeid: ID?, routename: String) {
        self.routeid = routeid
        self.routename = routename
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Route: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Route: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Route: Parameter { }
