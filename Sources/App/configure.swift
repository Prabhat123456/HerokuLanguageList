import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Database
    let config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "philips", database: "languagelist", password: nil, transport: .cleartext)
    let postgres = PostgreSQLDatabase(config: config)
    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: WordModel.self, database: .psql)
    migrations.add(model: LanguageSet.self, database: .psql)
    migrations.add(model: LanguageSupported.self, database: .psql)
    migrations.add(model: WordCollection.self, database: .psql)
    services.register(migrations)
}
