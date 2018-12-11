//
//  middlewares.swift
//  App
//
//  Created by Jacob Rhoda on 11/29/18.
//

import Vapor
import Authentication

public func middlewares(config: inout MiddlewareConfig) throws {
    config.use(FileMiddleware.self) // Serves files from `Public/` directory
    config.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    config.use(UnauthenticatedRedirectMiddleware.login()) // Catches unauthenticated errors and redirects to '/login'
    config.use(SessionsMiddleware.self) // Handles sessions.
}
