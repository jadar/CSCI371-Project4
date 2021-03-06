//
//  RegistrationController.swift
//  App
//
//  Created by Jacob Rhoda on 12/6/18.
//

import Vapor

final class RegistrationController {
    func boot(_ router: Router) {
        router.get("register", use: index)
        router.post("register", use: registrationForm)
    }

    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        let renderer = try req.view()
        return renderer.render("register")
    }

    func registrationForm(_ req: Request) throws -> Future<Response> {
        struct RegistrationContent: Content {
            var username: String
            var password: String
        }

        let contentFuture = try req.content.decode(RegistrationContent.self)
        let future = contentFuture
            .flatMap { (content) -> Future<User> in
                let user = try User(userID: nil, username: content.username, email: "", password: content.password, type: .administrator)
                return user.create(on: req)
            }
            .map { _ in req.redirect(to: "/login") }

        return future
    }
}
