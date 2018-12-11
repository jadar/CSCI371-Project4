//
//  DispatchController.swift
//  App
//
//  Created by Jacob Rhoda on 12/10/18.
//

import Vapor

final class DispatchController {
    func boot(_ router: Router) {
        router.get("dispatches", use: index)
        router.get("orders", use: index)
    }

    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        let renderer = try req.view()
        return renderer.render("dispatches")
    }
}
