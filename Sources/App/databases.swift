//
//  databases.swift
//  App
//
//  Created by Jacob Rhoda on 11/29/18.
//

import Vapor
import FluentMySQL
import DotEnv

public func databases(config: inout DatabasesConfig) throws {
    let env = DotEnv(withFile: "env")

    guard let dbUsername = env["db_username"],
        let dbPassword = env["db_password"],
        let dbName = env["db_name"] else {
            throw VaporError(identifier: "DBError", reason: "Missing env config variables. Needs db_username, db_password, db_name.")
    }

    // Configure MySQL database.
    let mysql = MySQLDatabase(config: MySQLDatabaseConfig(hostname: "127.0.0.1",
                                                          port: 3306,
                                                          username: dbUsername,
                                                          password: dbPassword,
                                                          database: dbName,
                                                          capabilities: .default,
                                                          characterSet: .utf8_general_ci,
                                                          transport: .cleartext))
    config.add(database: mysql, as: .mysql)

    // Set default databases. Note this is poor Swift API design by the Vapor creators.
    Container.defaultDatabase = .mysql
    Customer.defaultDatabase = .mysql
    Dispatch.defaultDatabase = .mysql
    Driver.defaultDatabase = .mysql
    Radio.defaultDatabase = .mysql
    Region.defaultDatabase = .mysql
    Route.defaultDatabase = .mysql
    RoutePoint.defaultDatabase = .mysql
    Truck.defaultDatabase = .mysql
    TruckRegion.defaultDatabase = .mysql
    User.defaultDatabase = .mysql
    Waypoint.defaultDatabase = .mysql

//    /// Configure migrations
//    var migrations = MigrationConfig()
//    migrations.add(model: Todo.self, database: .sqlite)
//    services.register(migrations)
}
