//
//  LoginController.swift
//  App
//
//  Created by Jacob Rhoda on 11/28/18.
//

import Vapor
import Authentication

final class LoginController {
    func boot(_ router: Router) {
        router.get("login", use: index)
        router.post("login", use: loginForm)
        router.get("logout", use: logout)
    }

    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        let renderer = try req.view()
        return renderer.render("login")
    }

    func loginForm(_ req: Request) throws -> Future<Response> {
//        let renderer = try req.view()
        struct LoginContent: Content {
            var username: String
            var password: String
        }

        let contentFuture = try req.content.decode(LoginContent.self)
        let userFuture = contentFuture.then { (content) -> Future<User?> in
            return User.authenticate(username: content.username, password: content.password, using: BCryptDigest(), on: req)
        }

        return userFuture.map { (user) -> (Response) in
            guard let user = user else {
                throw Abort(.forbidden)
            }
            try req.authenticate(user)
            return req.redirect(to: "/")
        }
    }

    func logout(_ req: Request) throws -> Response {
        try req.unauthenticate(User.self)
        return req.redirect(to: "/login")
    }
}
