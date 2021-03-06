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

        return driverParent.get(on: req).flatMap({ driver -> Future<View> in
            let dispatchesFuture = try driver.dispatches.query(on: req)
                .filter(\.dispdate, .greaterThanOrEqual, today)
                .all()

            let numDispatchesFuture = try driver.dispatches.query(on: req)
                .filter(\.dispdate, .greaterThanOrEqual, startOfWeek)
                .filter(\.dispdate, .lessThanOrEqual, endOfWeek)
                .count()

            return flatMap(dispatchesFuture, numDispatchesFuture) { (dispatches, numDispatches) -> Future<View> in
                return renderer.render("dashbaord-driver", DriverContext(user: user, dispatches: dispatches, numDispatches: numDispatches))
            }
        })


    }

    private func renderAdminDashboard(on req: Request, with user: User) throws -> Future<View> {
        struct AdminContext: Encodable {
            var user: User
            var dispatches: [DispatchController.DispatchResponse]
            var numSales: Int
            var numDispatches: Int
            var menuItems: [MenuItem]
            var routeType = RouteType.home

            init(user: User, dispatches: [DispatchController.DispatchResponse], numSales: Int, numDispatches: Int) {
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
            .filter(\Dispatch.dispdate, .greaterThanOrEqual, today)
            .all()
            .flatMap { (dispatches) -> Future<[DispatchController.DispatchResponse]> in
                let futures = dispatches.map { dispatch -> Future<(Dispatch, (Customer, Driver?))> in
                        let customerQuery = dispatch.customer.get(on: req)
                        let driverQuery: Future<Driver?> = dispatch.driver?.get(on: req).map({ $0 }) ?? req.future(nil)
                        return req.future(dispatch).and(customerQuery.and(driverQuery))
                    }

                return futures
                    .flatten(on: req)
                    .map { (data) -> ([DispatchController.DispatchResponse]) in
                        return data.map({ (dispatch, additionalData) -> DispatchController.DispatchResponse in
                            let (customer, driver) = additionalData
                            return DispatchController.DispatchResponse(dispatch: dispatch, customer: customer.shortName, driver: driver?.shortName)
                        })
                    }
            }
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
