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
    var routeid: Route.ID?
    var custid: Customer.ID
    var truckid: Truck.ID
    var driverid: Driver.ID?

    var streetAddress: String?
    var city: String?
    var state: String?

    static var idKey: IDKey = \.dispid

    var truck: Parent<Dispatch, Truck> {
        return parent(\.truckid)
    }

    var customer: Parent<Dispatch, Customer> {
        return parent(\.custid)
    }

    var driver: Parent<Dispatch, Driver>? {
        return parent(\.driverid)
    }

    /// Creates a new ``.
    init(dispid: ID?, dispdate: Date, orderdate: Date, price: Double, streetAddress: String?, city: String?, state: String?, routeid: Route.ID?, custid: Customer.ID, truckid: Truck.ID) {
        self.dispid = dispid
        self.dispdate = dispdate
        self.orderdate = orderdate
        self.price = price
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.routeid = routeid
        self.custid = custid
        self.truckid = truckid
    }

    func willCreate(on conn: MySQLConnection) throws -> EventLoopFuture<Dispatch> {
        return Dispatch
            .query(on: conn)
            .max(\.dispid)
            .map({ (possibleMaxID) -> Dispatch in
            let newID: String
            if let maxIDStr = possibleMaxID?.dropFirst(2),
                let maxID = Int(maxIDStr) {
                newID = "DP\(maxID + 1)"
            } else {
                newID = "DP1"
            }

            self.dispid = newID
            return self
        })
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Dispatch: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Dispatch: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Dispatch: Parameter { }
