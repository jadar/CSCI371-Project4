//
//  DashboardController.swift
//  App
//
//  Created by Jacob Rhoda on 12/8/18.
//

import Vapor
import DateToolsSwift

final class DashboardController {
    func boot(_ router: Router) {
        router.get(use: index)
    }

    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        let user = try req.requireAuthenticated(User.self)

        switch user.type {
        case .administrator: return try renderAdminDashboard(on: req, with: user)
        case .driver: return try renderDriverDashboard(on: req, with: user)
        }
    }

    private func renderDriverDashboard(on req: Request, with user: User) throws -> Future<View> {
        struct DriverContext: Encodable {
            var user: User
            var dispatches: [Dispatch]
            var numDispatches: Int
            var menuItems: [MenuItem]
            var routeType = RouteType.home

            init(user: User, dispatches: [Dispatch], numDispatches: Int) {
                self.user = user
                self.dispatches = dispatches
                self.numDispatches = numDispatches
                self.menuItems = user.availableMenuItems
            }
        }

        let renderer = try req.view()

        let today = Date()
        let startOfWeek = today.weekday.days.earlier
        let endOfWeek = 6.days.later(than: startOfWeek)

        guard let driverParent = user.driver else {
            throw Abort(.internalServerError)
        }

        let dispatchesFuture = driverParent.get(on: req).flatMap({ driver -> Future<[Dispatch]> in
            driver.dispatchQuery(on: req)
                .filter(\.dispdate, .greaterThanOrEqual, today)
                .all()
        })

        let numDispatchesFuture = Dispatch.query(on: req)
            .filter(\.dispdate, .greaterThanOrEqual, startOfWeek)
            .filter(\.dispdate, .lessThanOrEqual, endOfWeek)
            .count()

        return flatMap(dispatchesFuture, numDispatchesFuture) { (dispatches, numDispatches) -> Future<View> in
            return renderer.render("dashbaord-driver", DriverContext(user: user, dispatches: dispatches, numDispatches: numDispatches))
        }
    }

    private func renderAdminDashboard(on req: Request, with user: User) throws -> Future<View> {
        struct AdminContext: Encodable {
            var user: User
            var dispatches: [Dispatch]
            var numSales: Int
            var numDispatches: Int
            var menuItems: [MenuItem]
            var routeType = RouteType.home

            init(user: User, dispatches: [Dispatch], numSales: Int, numDispatches: Int) {
                self.user = user
                self.numSales = numSales
                self.dispatches = dispatches
                self.numDispatches = numDispatches
                self.menuItems = user.availableMenuItems
            }
        }

        let renderer = try req.view()

        let today = Date()
        let startOfWeek = today.weekday.days.earlier
        let endOfWeek = 6.days.later(than: startOfWeek)

        let dispatchesFuture = Dispatch.query(on: req)
                                               .filter(\.dispdate, .greaterThanOrEqual, today)
                                               .all()
        let numSalesFuture = Dispatch.query(on: req)
                                     .filter(\.orderdate, .greaterThanOrEqual, startOfWeek)
                                     .filter(\.orderdate, .lessThanOrEqual, endOfWeek)
                                     .count()
        let numDispatchesFuture = Dispatch.query(on: req)
                                          .filter(\.dispdate, .greaterThanOrEqual, startOfWeek)
                                          .filter(\.dispdate, .lessThanOrEqual, endOfWeek)
                                          .count()

        return flatMap(dispatchesFuture, numSalesFuture, numDispatchesFuture) { (dispatches, numSales, numDispatches) -> Future<View> in
            return renderer.render("dashboard-admin", AdminContext(user: user, dispatches: dispatches, numSales: numSales, numDispatches: numDispatches))
        }
    }
}
