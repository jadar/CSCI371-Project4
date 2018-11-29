//
//  Dispatch.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class Dispatch: _MySQLModel {
    typealias ID = String

    var dispid: ID?
    var dispdate: Date
    var orderdate: Date
    var price: Double
    var routeid: Route.ID
    var custid: Customer.ID
    var truckid: Truck.ID

    static var idKey: IDKey = \.dispid

    /// Creates a new ``.
    init(dispid: ID?, dispdate: Date, orderdate: Date, price: Double, routeid: Route.ID, custid: Customer.ID, truckid: Truck.ID) {
        self.dispid = dispid
        self.dispdate = dispdate
        self.orderdate = orderdate
        self.price = price
        self.routeid = routeid
        self.custid = custid
        self.truckid = truckid
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Dispatch: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Dispatch: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Dispatch: Parameter { }
