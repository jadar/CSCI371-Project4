import Vapor
import FluentMySQL
import Authentication
import Leaf

typealias MySQLCache = DatabaseKeyedCache<ConfiguredDatabase<MySQLDatabase>>

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())

    let session = User.authSessionsMiddleware()

    /// Register routes to the router
    let router = EngineRouter.default()
    let authenticatedRouter = router.grouped(session)
    try routes(authenticatedRouter)
    
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewaresConfig = MiddlewareConfig() // Create empty middleware config
    try middlewares(config: &middlewaresConfig)
    services.register(middlewaresConfig)

    /// Register the configured SQLite database to the database config.
    var databasesConfig = DatabasesConfig()
    try databases(services: &services, config: &databasesConfig)
    services.register(databasesConfig)

    /// Register MySQL as a cache provider.
    services.register(KeyedCache.self) { container -> MySQLCache in
        let pool = try container.connectionPool(to: .mysql)
        return .init(pool: pool)
    }
    config.prefer(MySQLCache.self, for: KeyedCache.self)

    // Configure the templating engine.
    let leaf = LeafProvider()
    try services.register(leaf)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}

