//
//  DriverController.swift
//  App
//
//  Created by Jacob Rhoda on 11/13/18.
//

import Vapor

final class DriverController {
    /// Returns a list of all `Driver`s.
    func index(_ req: Request) throws -> Future<View> {
        let renderer = try req.view()

        return Driver.query(on: req).all().then { (res) -> Future<View> in
            return renderer.render("index", ["data": res])
        }
    }
}
