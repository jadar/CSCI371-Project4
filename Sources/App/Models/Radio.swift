//
//  Radio.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class Radio: _MySQLModel {
    typealias ID = String

    var radioid: String?

    static var idKey: IDKey = \.radioid

    /// Creates a new `Driver`.
    init(radioid: String?) {
        self.radioid = radioid
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Radio: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Radio: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Radio: Parameter { }

