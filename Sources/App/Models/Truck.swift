//
//  Truck.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class Truck: _MySQLModel {
    typealias ID = String

    var truckid: ID?
    var truckmodel: String
    var misinceoilchange: Int
    var ownerdriverid: Driver.ID

    static var idKey: IDKey = \.truckid

    var drivers: Children<Truck, Driver> {
        return children(\.drivingtruckid)
    }

    /// Creates a new ``.
    init(truckid: ID?, truckmodel: String, misinceoilchange: Int, ownerdriverid: Driver.ID) {
        self.truckid = truckid
        self.truckmodel = truckmodel
        self.misinceoilchange = misinceoilchange
        self.ownerdriverid = ownerdriverid
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Truck: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Truck: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Truck: Parameter { }
