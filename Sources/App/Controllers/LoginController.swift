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

    func loginForm(_ req: Request) throws -> Future<AnyResponse> {
        struct LoginContent: Content {
            var username: String
            var password: String
        }

        struct LoginErrorContent: Error, Encodable {
            var error: String
            var usernameInput: String
        }

        let renderer = try req.view() // Grab a renderer.

        let contentFuture = try req.content.decode(LoginContent.self)  // Decode the form data.

        // Construct a future that tries to authenticate with the given username/password.
        // Compounds the user for additional context.
        let userFuture = contentFuture
            .then { User.authenticate(username: $0.username, password: $0.password, on: req).and(result: $0) }
            .flatMap { (result, content) -> Future<AnyResponse> in
                guard let user = result else {
                    // Renders the login view again if authentication failed.
                    let err = LoginErrorContent(error: "Invalid login", usernameInput: content.username)
                    return renderer.render("login", err).map(AnyResponse.init)
                }

                // Authenticate the request with the user.
                try req.authenticate(user)

                // Redirects if there was authentication.
                return req.future(AnyResponse(req.redirect(to: "/")))
            }

        return userFuture
    }

    func logout(_ req: Request) throws -> Response {
        try req.unauthenticateSession(User.self)
        return req.redirect(to: "/login")
    }
}
