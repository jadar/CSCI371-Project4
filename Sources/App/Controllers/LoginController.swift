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
        struct LoginContent: Content {
            var username: String
            var password: String
        }

        let renderer = try req.view()
        let contentFuture = try req.content.decode(LoginContent.self)
        let userFuture = contentFuture.then { (content) -> Future<User?> in
            return User.authenticate(username: content.username, password: content.password, using: BCryptDigest(), on: req)
        }.map { (result) -> User? in
            if let user = result {
                try req.authenticate(user)
            }

            return result
        }

        let responseFuture = userFuture.then { (result) -> EventLoopFuture<Response> in
            if result != nil {
                let redirectResponse = req.redirect(to: "/")
                return req.future(redirectResponse)
            } else {
                return renderer.render("login").map { (view) -> Response in
                    let response = req.response()
                    try response.content.encode(view)
                    return response
                }
            }
        }
        
        return responseFuture
    }

    func logout(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/login")
    }
}
