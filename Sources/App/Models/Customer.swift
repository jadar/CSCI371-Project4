//
//  Customer.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class Customer: _MySQLModel {
    typealias ID = String

    var custid: ID?
    var custfname: String
    var custlname: String
    var referrercustid: ID?

    static var idKey: IDKey = \.custid

    var dispatches: Children<Customer, Dispatch> {
        return children(\.custid)
    }

    var referrerCustomer: Parent<Customer, Customer>? {
        return parent(\.referrercustid)
    }

    func numDispatches(on conn: DatabaseConnectable) throws -> Int {
        return try dispatches.query(on: conn).count().wait()
    }

    var shortName: String {
        var name = ""
        if let firstChar = custfname.first {
            name += "\(firstChar). "
        }
        name += custlname
        name += " (\(custid!))"
        return name
    }

    /// Creates a new ``.
    init(custid: ID?, custfname: String, custlname: String, referrercustid: ID?) {
        self.custid = custid
        self.custfname = custfname
        self.custlname = custlname
        self.referrercustid = referrercustid
    }

    
}

/// Allows `Building` to be used as a dynamic migration.
extension Customer: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Customer: Content {}

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Customer: Parameter { }
