//
//  Waypoint.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class Waypoint: _MySQLModel {
    typealias ID = String

    var stopid: ID?
    var latitude: Double
    var longitude: Double

    static var idKey: IDKey = \.stopid

    /// Creates a new ``.
    init(stopid: ID?, latitude: Double, longitude: Double) {
        self.stopid = stopid
        self.latitude = latitude
        self.longitude = longitude
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Waypoint: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Waypoint: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Waypoint: Parameter { }
