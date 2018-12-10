//
//  DriverController.swift
//  App
//
//  Created by Jacob Rhoda on 11/13/18.
//

import Vapor

final class DriverController {
    struct DriverContext: Encodable {
        var data: [Driver]
        var user: User
    }

    func boot(_ router: Router) {
        router.get("drivers", use: index)
    }

    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        let renderer = try req.view()
        let user = try req.requireAuthenticated(User.self)

        return Driver.query(on: req).all().then { (res) -> Future<View> in
            let context = DriverContext(data: res, user: user)
            return renderer.render("drivers", context)
        }
    }
}
