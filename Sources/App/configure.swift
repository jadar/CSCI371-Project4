import FluentSQLite
import MySQL
import Vapor
import Leaf

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentSQLiteProvider())

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response

    services.register(middlewares)

    // Configure MySQL database.
    let mysql = MySQLDatabase(config: MySQLDatabaseConfig(hostname: "127.0.0.1",
                                                          port: 3306,
                                                          username: "",
                                                          password: "",
                                                          database: "proj",
                                                          capabilities: .default,
                                                          characterSet: .utf8_general_ci,
                                                          transport: .cleartext))

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: mysql, as: .mysql)
    services.register(databases)

    // Set default databases.
    Driver.defaultDatabase = .mysql

//    /// Configure migrations
//    var migrations = MigrationConfig()
//    migrations.add(model: Todo.self, database: .sqlite)
//    services.register(migrations)


    // Configure the templating engine.
    let leaf = LeafProvider()
    try services.register(leaf)
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
}

