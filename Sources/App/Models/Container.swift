//
//  Container.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class Container: _MySQLModel {
    typealias ID = String

    var containerid: ID?
    var dispid: Dispatch.ID
    var contents: String
    var weight: Double
    var insuredvalue: Double

    static var idKey: IDKey = \.containerid

    /// Creates a new ``.
    init(containerid: ID?, dispid: Dispatch.ID, contents: String, weight: Double, insuredvalue: Double) {
        self.containerid = containerid
        self.dispid = dispid
        self.contents = contents
        self.weight = weight
        self.insuredvalue = insuredvalue
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension Container: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension Container: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension Container: Parameter { }

