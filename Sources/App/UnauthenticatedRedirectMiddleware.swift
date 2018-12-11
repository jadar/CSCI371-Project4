//
//  UnauthenticatedRedirectMiddleware.swift
//  App
//
//  Created by Jacob Rhoda on 12/9/18.
//

import Vapor
import Authentication

public final class UnauthenticatedRedirectMiddleware: Middleware {
    var path: String

    public init(path: String) {
        self.path = path
    }
    
    /// See `Middleware`.
    public func respond(to req: Request, chainingTo next: Responder) throws -> Future<Response> {
        let response: Future<Response>
        do {
            response = try next.respond(to: req)
        } catch {
            guard let _ = error as? AuthenticationError else { throw error }
            response = req.future(req.redirect(to: path))
        }

        return response
    }

    public static func login(path: String = "/login") -> UnauthenticatedRedirectMiddleware {
        return UnauthenticatedRedirectMiddleware(path: path)
    }
}

