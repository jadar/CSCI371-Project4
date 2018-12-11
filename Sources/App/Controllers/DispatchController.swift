//
//  DispatchController.swift
//  App
//
//  Created by Jacob Rhoda on 12/10/18.
//

import Vapor
import DateToolsSwift

final class DispatchController {
    func boot(_ router: Router) {
        router.get("dispatches", use: index)
        router.get("orders", use: index)

        router.get("dispatches", PathComponent.parameter("dispatch"), use: single)
    }

    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        let user = try req.requireAuthenticated(User.self)
        switch user.type {
        case .administrator: return try renderAllDispatches(req, with: user)
        case .driver:
            guard let driverFuture = user.driver?.get(on: req) else { throw Abort(.internalServerError) }
            return driverFuture.flatMap({ [unowned self] in try self.renderDriverDispatches(req, with: user, and: $0) })
        }
    }

    private struct DispatchResponse: Encodable {
        var dispid: String
        var dispdate: Date
        var orderdate: Date
        var price: Double
        var customername: String
        var drivername: String

        init(dispatch: Dispatch, customer: String, driver: String) {
            dispid = dispatch.dispid!
            dispdate = dispatch.dispdate
            orderdate = dispatch.orderdate
            price = dispatch.price
            self.customername = customer
            self.drivername = driver
        }
    }

    private struct DispatchesContext: Encodable {
        var user: User
        var dispatches: [DispatchResponse]
        var pageTitle: String

        var menuItems: [MenuItem]
        var routeType = RouteType.orders

        init(user: User, dispatches: [DispatchResponse], pageTitle: String) {
            self.user = user
            self.dispatches = dispatches
            self.pageTitle = pageTitle
            self.menuItems = user.availableMenuItems
        }
    }

    func renderAllDispatches(_ req: Request, with user: User) throws -> Future<View> {
        let renderer = try req.view()

        let today = Date()
        let startOfWeek = today.weekday.days.earlier

        return Dispatch.query(on: req)
            .filter(\.dispdate, .greaterThanOrEqual, startOfWeek)
            .all()
            .flatMap { (dispatches) -> Future<View> in
                let futures = dispatches.map({ dispatch -> Future<(Dispatch, (Customer, Driver?))> in
                    let customerQuery = dispatch.customer.get(on: req)
                    let driverQuery: Future<Driver?> = dispatch.driver?.get(on: req).map({ $0 }) ?? req.future(nil)
                    return req.future(dispatch).and(customerQuery.and(driverQuery))
                })

                return futures
                    .flatten(on: req)
                    .map { (data) -> ([DispatchResponse]) in
                        data.map({ (dispatch, additionalData) -> DispatchResponse in
                            let (customer, driver) = additionalData
                            return DispatchResponse(dispatch: dispatch, customer: customer.shortName, driver: driver?.shortName ?? "Not assigned")
                        })
                    }
                    .flatMap { renderer.render("dispatches", DispatchesContext(user: user, dispatches: $0, pageTitle: "Orders")) }
        }
    }

    func renderDriverDispatches(_ req: Request, with user: User, and driver: Driver) throws -> Future<View> {
        let renderer = try req.view()

        let today = Date()
        let startOfWeek = today.weekday.days.earlier

        return driver.dispatchQuery(on: req)
            .filter(\.dispdate, .greaterThanOrEqual, startOfWeek)
            .all()
            .flatMap { (dispatches) -> Future<View> in
                let futures = dispatches.map({ dispatch -> Future<(Dispatch, (Customer, Driver?))> in
                    let customerQuery = dispatch.customer.get(on: req)
                    let driverQuery: Future<Driver?> = dispatch.driver?.get(on: req).map({ $0 }) ?? req.future(nil)
                    return req.future(dispatch).and(customerQuery.and(driverQuery))
                })

                return futures
                    .flatten(on: req)
                    .map { (data) -> ([DispatchResponse]) in
                        data.map({ (dispatch, additionalData) -> DispatchResponse in
                            let (customer, driver) = additionalData
                            return DispatchResponse(dispatch: dispatch, customer: customer.shortName, driver: driver?.shortName ?? "Not assigned")
                        })
                    }
                    .flatMap { renderer.render("dispatches", DispatchesContext(user: user, dispatches: $0, pageTitle: "My Dispatches")) }
        }
    }

    /// Returns a list of all `Driver`s.
    func single(_ req: Request) throws -> Future<View> {
        struct SingleDispatchContext: Encodable {
            var user: User
            var dispatch: DispatchResponse
            var menuItems: [MenuItem]
            var routeType = RouteType.orders

            init(user: User, dispatch: DispatchResponse) {
                self.user = user
                self.dispatch = dispatch
                self.menuItems = user.availableMenuItems
            }
        }

        let renderer = try req.view()
        let user = try req.requireAuthenticated(User.self)
        let dispatchFuture = try req.parameters.next(Dispatch.self)

        return dispatchFuture
            .flatMap { dispatch -> Future<View> in
                let response = DispatchResponse(dispatch: dispatch, customer: "", driver: "")
                return renderer.render("single_dispatch", SingleDispatchContext(user: user, dispatch: response))
        }
    }
}
