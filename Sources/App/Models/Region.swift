//
//  Region.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class Region: _MySQLModel {
    typealias ID = String

    var regionid: ID?
    var regionname: String

    static var idKey: IDKey = \.regionid

    /// Creates a new ``.
    init(regionid: ID?, regionname: String) {
        self.regionid = regionid
        self.regionname = regionname
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Region: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Region: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Region: Parameter { }
