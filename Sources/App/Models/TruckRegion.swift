//
//  TruckRegion.swift
//  App
//
//  Created by Jacob Rhoda on 11/27/18.
//

import FluentMySQL
import Vapor

final class TruckRegion: MySQLPivot {
    typealias Left = Truck
    typealias Right = Region

    static var leftIDKey: WritableKeyPath<TruckRegion, String> = \.truckid
    static var rightIDKey: WritableKeyPath<TruckRegion, String> = \.regionid

    var id: Int?

    var truckid: Truck.ID
    var regionid: Region.ID

    /// Creates a new ``.
    init(truckid: Truck.ID, regionid: Region.ID) {
        self.truckid = truckid
        self.regionid = regionid
    }
}

/// Allows `Building` to be used as a dynamic migration.
extension TruckRegion: Migration { }

/// Allows `Building` to be encoded to and decoded from HTTP messages.
extension TruckRegion: Content { }

/// Allows `Building` to be used as a dynamic parameter in route definitions.
extension TruckRegion: Parameter { }
