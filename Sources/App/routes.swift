import Vapor

enum RouteType: String, Encodable, CaseIterable {
    case home
    case orders
    case customers
    case drivers
}

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

    let dispatchController = DispatchController()
    dispatchController.boot(router)
}

struct MenuItem: Encodable {
    var title: String
    var path: String
    var icon: String
    var routeType: RouteType
}

extension User {
    var availableMenuItems: [MenuItem] {
        switch type {
        case .administrator: return [
            MenuItem(title: "Home", path: "/", icon: "fe fe-home", routeType: .home),
            MenuItem(title: "Orders", path: "/orders", icon: "fe fe-box", routeType: .orders),
            MenuItem(title: "Customers", path: "/customers", icon: "fe fe-users", routeType: .customers),
            MenuItem(title: "Drivers", path: "/drivers", icon: "fe fe-truck", routeType: .drivers)
            ]
        case .driver: return [
            MenuItem(title: "Home", path: "/", icon: "fe fe-home", routeType: .home),
            MenuItem(title: "My Dispatches", path: "/dispatches", icon: "fe fe-truck", routeType: .orders)
            ]
        }
    }
}
