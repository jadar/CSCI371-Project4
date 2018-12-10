import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let loginController = LoginController()
    loginController.boot(router)

    let registrationController = RegistrationController()
    registrationController.boot(router)

    let dashboardController = DashboardController()
    dashboardController.boot(router)

    // Configure the driver controller.
    let driverController = DriverController()
    driverController.boot(router)
}
