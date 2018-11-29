//
//  Driver.swift
//  App
//
//  Created by Jacob Rhoda on 11/12/18.
//

import FluentMySQL
import Vapor

final class Driver: _MySQLModel {
    typealias ID = String

    var driverid: String?
    var driverlicenseno: String
    var driverfname: String
    var driverlname: String
    var callsign: String
    var dateofbirth: Date
    var radioid: Radio.ID
    var drivingtruckid: Truck.ID?

    static var idKey: IDKey = \.driverid

    /// Creates a new `Driver`.
    init(driverid: String?, driverlicenseno: String, driverfname: String, driverlname: String, callsign: String, dateofbirth: Date, radioid: Radio.ID, drivingtruckid: Truck.ID?) {
        self.driverid = driverid
        self.driverlicenseno = driverlicenseno
        self.driverfname = driverfname
        self.driverlname = driverlname
        self.callsign = callsign
        self.dateofbirth = dateofbirth
        self.radioid = radioid
        self.drivingtruckid = drivingtruckid
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Driver: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Driver: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Driver: Parameter { }
