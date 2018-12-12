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
        router.get("dispatches", PathComponent.parameter("dispatch"), "edit", use: edit)
        router.get("dispatches", "new", use: new)
        router.get("dispatches", PathComponent.parameter("dispatch"), "assign_driver", use: assignDriver)
        router.post("dispatches", PathComponent.parameter("dispatch"), "assign_driver", use: assignDriverFormSubmit)

        router.post("dispatches", use: editFormSubmitNew)
        router.post("dispatches", PathComponent.parameter("dispatch"), use: editFormSubmitExisting)
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

    struct DispatchResponse: Encodable {
        var dispid: String
        var dispdate: Date
        var orderdate: Date
        var price: Double
        var streetAddress: String
        var city: String
        var state: String
        var customername: String
        var drivername: String?

        var truckid: String
        var custid: String

        init(dispatch: Dispatch, customer: String, driver: String?) {
            dispid = dispatch.dispid!
            dispdate = dispatch.dispdate.addingTimeInterval(6*60*60)
            orderdate = dispatch.orderdate.addingTimeInterval(6*60*60)
            price = dispatch.price
            streetAddress = dispatch.streetAddress ?? ""
            city = dispatch.city ?? ""
            state = dispatch.state ?? ""
            truckid = dispatch.truckid
            custid = dispatch.custid
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
                            return DispatchResponse(dispatch: dispatch, customer: customer.shortName, driver: driver?.shortName)
                        })
                    }
                    .flatMap { renderer.render("dispatches", DispatchesContext(user: user, dispatches: $0, pageTitle: "Orders")) }
        }
    }

    func renderDriverDispatches(_ req: Request, with user: User, and driver: Driver) throws -> Future<View> {
        let renderer = try req.view()

        let today = Date()
        let startOfWeek = today.weekday.days.earlier

        return try driver.dispatches.query(on: req)
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
                            return DispatchResponse(dispatch: dispatch, customer: customer.shortName, driver: driver?.shortName)
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

        return dispatchFuture.flatMap({ (dispatch) -> EventLoopFuture<View> in
            let customerQuery = dispatch.customer.get(on: req)
            let driverQuery: Future<Driver?> = dispatch.driver?.get(on: req).map({ $0 }) ?? req.future(nil)
            let combinedQuery = customerQuery.and(driverQuery)

            return combinedQuery.map(to: DispatchResponse.self, { (arg0) -> DispatchResponse in
                let (customer, driver) = arg0
                return DispatchResponse(dispatch: dispatch, customer: customer.shortName, driver: driver?.shortName)
            }).flatMap(to: View.self, { (response) -> EventLoopFuture<View> in
                return renderer.render("single_dispatch", SingleDispatchContext(user: user, dispatch: response))
            })
        })
    }

    func new(_ req: Request) throws -> Future<View> {
        struct NewDispatchContext: Encodable {
            var user: User
            var customers: [Customer]
            var trucks: [Truck]

            var menuItems: [MenuItem]
            var routeType = RouteType.orders

            init(user: User, customers: [Customer], trucks: [Truck]) {
                self.user = user
                self.menuItems = user.availableMenuItems
                self.customers = customers
                self.trucks = trucks
            }
        }

        let renderer = try req.view()
        let user = try req.requireAuthenticated(User.self)

        let customersQuery = Customer.query(on: req).all()
        let trucksQuery = Truck.query(on: req).all()

        return flatMap(customersQuery, trucksQuery, { (customers, trucks) -> Future<View> in
            renderer.render("dispatch-edit", NewDispatchContext(user: user, customers: customers, trucks: trucks))
        })
    }

    func edit(_ req: Request) throws -> Future<View> {
        struct EditDispatchContext: Encodable {
            var user: User
            var dispatch: DispatchResponse
            var customers: [Customer]
            var trucks: [Truck]

            var menuItems: [MenuItem]
            var routeType = RouteType.orders

            init(user: User, dispatch: DispatchResponse, customers: [Customer], trucks: [Truck]) {
                self.user = user
                self.dispatch = dispatch
                self.menuItems = user.availableMenuItems
                self.customers = customers
                self.trucks = trucks
            }
        }

        let renderer = try req.view()
        let user = try req.requireAuthenticated(User.self)
        let dispatchFuture = try req.parameters.next(Dispatch.self)

        return dispatchFuture.flatMap({ (dispatch) -> Future<View> in
            let customerQuery = dispatch.customer.get(on: req)
            let driverQuery: Future<Driver?> = dispatch.driver?.get(on: req).map({ $0 }) ?? req.future(nil)
            let customersQuery = Customer.query(on: req).all()
            let trucksQuery = Truck.query(on: req).all()

            let dispatchResponseFuture = customerQuery
                .and(driverQuery)
                .map(to: DispatchResponse.self, { (arg0) -> DispatchResponse in
                    let (customer, driver) = arg0
                    return DispatchResponse(dispatch: dispatch, customer: customer.shortName, driver: driver?.shortName ?? "Not assigned")
                })

            return flatMap(to: View.self, dispatchResponseFuture, customersQuery, trucksQuery) { (response, allCustomers, trucks) throws -> Future<View> in
                return renderer.render("dispatch-edit", EditDispatchContext(user: user, dispatch: response, customers: allCustomers, trucks: trucks))
            }
        })
    }

    func editFormSubmitNew(_ req: Request) throws -> Future<Response> {
        return try _editFormSubmit(req, with: nil)
    }

    func editFormSubmitExisting(_ req: Request) throws -> Future<Response> {
        let dispatch = try req.parameters.next(Dispatch.self)
        return dispatch.flatMap(to: Response.self) { [unowned self] in try self._editFormSubmit(req, with: $0) }
    }

    private func _editFormSubmit(_ req: Request, with dispatch: Dispatch?) throws -> Future<Response> {
        struct FormContent: Content {
            var dispdate: String
            var price: Double
            var streetAddress: String
            var city: String
            var state: String
            var custid: String
            var truckid: String
        }

        let contentFuture = try req.content.decode(FormContent.self)
        return contentFuture.flatMap { (form) -> EventLoopFuture<Response> in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            guard let date = dateFormatter.date(from: form.dispdate) else { throw Abort(.badRequest) }

            let dispatchToSave: Dispatch
            if let dispatch = dispatch {
                dispatch.dispdate = date
                dispatch.price = form.price
                dispatch.streetAddress = !form.streetAddress.isEmpty ? form.streetAddress : nil
                dispatch.city = !form.city.isEmpty ? form.city : nil
                dispatch.state = !form.state.isEmpty ? form.state : nil
                dispatch.truckid = form.truckid
                dispatch.custid = form.custid

                dispatchToSave = dispatch
            } else {
                dispatchToSave = Dispatch(dispid: nil,
                                          dispdate: date,
                                          orderdate: Date(),
                                          price: form.price,
                                          streetAddress: !form.streetAddress.isEmpty ? form.streetAddress : nil,
                                          city: !form.city.isEmpty ? form.city : nil,
                                          state: !form.state.isEmpty ? form.state : nil,
                                          routeid: nil,
                                          custid: form.custid,
                                          truckid: form.truckid)
            }

            return dispatchToSave.save(on: req).map({ dispatch throws -> Response in
                return req.redirect(to: "/dispatches/\(dispatch.dispid!)/")
            })
        }
    }

    func assignDriver(_ req: Request) throws -> Future<View> {
        struct AssignDriverContext: Encodable {
            var user: User
            var dispatch: DispatchResponse
            var drivers: [Driver]
            var menuItems: [MenuItem]
            var routeType = RouteType.orders

            init(user: User, dispatch: DispatchResponse, drivers: [Driver]) {
                self.user = user
                self.dispatch = dispatch
                self.drivers = drivers
                self.menuItems = user.availableMenuItems
            }
        }

        let renderer = try req.view()
        let user = try req.requireAuthenticated(User.self)
        let dispatchFuture = try req.parameters.next(Dispatch.self)

        return dispatchFuture.flatMap({ (dispatch) -> EventLoopFuture<View> in
            let driversFuture = dispatch.truck.get(on: req).flatMap({ truck in
                try truck.drivers.query(on: req).all()
            })
            return driversFuture.flatMap({ (drivers) -> EventLoopFuture<View> in
                let response = DispatchResponse(dispatch: dispatch, customer: "", driver: nil)
                return renderer.render("assign-driver", AssignDriverContext(user: user, dispatch: response, drivers: drivers))
            })
        })
    }

    func assignDriverFormSubmit(_ req: Request) throws -> Future<Response> {
        struct FormContent: Content {
            var driverid: String
        }

        let dispatchFuture = try req.parameters.next(Dispatch.self)
        let contentFuture = try req.content.decode(FormContent.self)

        return flatMap(dispatchFuture, contentFuture, { (dispatch, content) -> Future<Response> in
            dispatch.driverid = content.driverid
            return dispatch.save(on: req).map({ _ in req.redirect(to: "/dispatches/\(dispatch.dispid!)") })
        })
    }
}
