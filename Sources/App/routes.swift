import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Configure the driver controller.
    let driverController = DriverController()
    router.get(use: driverController.index)
}
