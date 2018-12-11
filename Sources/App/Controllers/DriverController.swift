//
//  DriverController.swift
//  App
//
//  Created by Jacob Rhoda on 11/13/18.
//

import Vapor

final class DriverController {
    func boot(_ router: Router) {
        router.get("drivers", use: index)
    }

    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        struct DriverContext: Encodable {
            var user: User
            var drivers: [Driver]
            var menuItems: [MenuItem]
            var routeType = RouteType.drivers

            init(user: User, drivers: [Driver]) {
                self.user = user
                self.drivers = drivers
                self.menuItems = user.availableMenuItems
            }
        }

        let renderer = try req.view()
        let user = try req.requireAuthenticated(User.self)

        return Driver.query(on: req).all().then { (res) -> Future<View> in
            renderer.render("drivers", DriverContext(user: user, drivers: res))
        }
    }
}
