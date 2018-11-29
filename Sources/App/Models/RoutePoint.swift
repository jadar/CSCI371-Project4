//
//  RoutePoint.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class RoutePoint: MySQLPivot {
    typealias Left = Route
    typealias Right = Waypoint

    static var leftIDKey: WritableKeyPath<RoutePoint, String> = \.routeid
    static var rightIDKey: WritableKeyPath<RoutePoint, String> = \.stopid

    var id: Int? // UNUSED WHY?!

    var routeid: Route.ID
    var stopid: Waypoint.ID
    var order: Int

    /// Creates a new ``.
    init(routeid: Route.ID, stopid: Waypoint.ID, order: Int) {
        self.routeid = routeid
        self.stopid = stopid
        self.order = order
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension RoutePoint: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension RoutePoint: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension RoutePoint: Parameter { }
