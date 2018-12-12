//
//  CustomerController.swift
//  App
//
//  Created by Jacob Rhoda on 12/11/18.
//

import Vapor

final class CustomerController {
    func boot(_ router: Router) {
        router.get("customers", use: index)

        router.get("customers", PathComponent.parameter("customer"), use: edit)
        router.get("customers", "new", use: create)

        router.post("customers", PathComponent.parameter("customer"), use: editFormSubmitExisting)
        router.post("customers", use: editFormSubmitNew)
    }

    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        struct CustomerResponse: Encodable {
            var custid: String
            var custfname: String
            var custlname: String
            var referrername: String
            var numorders: Int
        }

        struct CustomerContext: Encodable {
            var user: User
            var customers: [CustomerResponse]
            var menuItems: [MenuItem]
            var routeType = RouteType.customers

            init(user: User, customers: [CustomerResponse]) {
                self.user = user
                self.customers = customers
                self.menuItems = user.availableMenuItems
            }
        }

        let renderer = try req.view()
        let user = try req.requireAuthenticated(User.self)

        // This probably looks like magic. But is, in fact, a perfectly logical, funcational, transformation incantation!
        return Customer.query(on: req)
            .all()
            .flatMap { customers -> Future<View> in
                let futures = try customers.map({ customer -> Future<(Customer, (Int, Customer?))> in
                    let numDispatchesQuery = try customer.dispatches.query(on: req).count()
                    let referrerQuery = customer.referrerCustomer?.get(on: req).map({ Optional.some($0) }) ?? req.future(nil)
                    return req.future(customer).and(numDispatchesQuery.and(referrerQuery))
                })

                return futures
                    .flatten(on: req)
                    .map { (data) -> ([CustomerResponse]) in
                        data.map({ (customer, additionalData) -> CustomerResponse in
                            let (numDispatches, referrerCustomer) = additionalData
                            let referrerName: String
                            if let referrerCust = referrerCustomer {
                                let firstCharacter = referrerCust.custfname.first ?? Character(" ")
                                referrerName = "\(firstCharacter). \(referrerCust.custlname) (\(referrerCust.custid!))"
                            } else {
                                referrerName = ""
                            }

                            return CustomerResponse(custid: customer.custid!, custfname: customer.custfname, custlname: customer.custlname, referrername: referrerName, numorders: numDispatches)
                        })
                    }
                    .flatMap { (responses) -> Future<View> in
                        return renderer.render("customers", CustomerContext(user: user, customers: responses))
                    }
        }
    }

    func edit(_ req: Request) throws -> Future<View> {
        let customerFuture = try req.parameters.next(Customer.self)
        return customerFuture.flatMap({ [unowned self] in try self._renderEdit(req, with: $0) })
    }

    func create(_ req: Request) throws -> Future<View> {
        return try _renderEdit(req, with: nil)
    }

    private func _renderEdit(_ req: Request, with customer: Customer?) throws -> Future<View> {
        struct EditContext: Encodable {
            var user: User
            var customer: Customer?
            var customers: [Customer]

            var menuItems: [MenuItem]
            var routeType = RouteType.customers

            init(user: User, customer: Customer?, customers: [Customer]) {
                self.user = user
                self.customer = customer
                self.menuItems = user.availableMenuItems
                self.customers = customers
            }
        }

        let renderer = try req.view()
        let user = try req.requireAuthenticated(User.self)
        let customersQuery = Customer.query(on: req).all()

        return customersQuery.flatMap { (allCustomers) throws -> Future<View> in
            return renderer.render("customer-edit", EditContext(user: user, customer: customer, customers: allCustomers))
        }
    }

    func editFormSubmitNew(_ req: Request) throws -> Future<Response> {
        return try _editFormSubmit(req, with: nil)
    }

    func editFormSubmitExisting(_ req: Request) throws -> Future<Response> {
        let dispatch = try req.parameters.next(Customer.self)
        return dispatch.flatMap(to: Response.self) { [unowned self] in try self._editFormSubmit(req, with: $0) }
    }

    private func _editFormSubmit(_ req: Request, with customer: Customer?) throws -> Future<Response> {
        struct FormContent: Content {
            var custfname: String
            var custlname: String
            var referrercustid: String
        }

        let contentFuture = try req.content.decode(FormContent.self)
        return contentFuture.flatMap { (form) -> EventLoopFuture<Response> in
            let toSave: Customer
            if let customer = customer {
                customer.custfname = form.custfname
                customer.custlname = form.custlname
                customer.referrercustid = !form.referrercustid.isEmpty ? form.referrercustid : nil

                toSave = customer
            } else {
                toSave = Customer(custid: nil,
                                  custfname: form.custfname,
                                  custlname: form.custlname,
                                  referrercustid: !form.referrercustid.isEmpty ? form.referrercustid : nil)
            }

            return toSave.save(on: req).map({ dispatch throws -> Response in
                return req.redirect(to: "/customers/")
            })
        }
    }
}

