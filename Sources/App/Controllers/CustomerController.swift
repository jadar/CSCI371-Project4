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
}

