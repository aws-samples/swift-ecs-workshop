
import URI
import HTTP
import Vapor
import VaporMySQL

let drop = Droplet(
    availableMiddleware: ["cors" : CorsMiddleware()],
    serverMiddleware: ["file", "cors"],
    preparations: [Product.self],
    providers: [VaporMySQL.Provider.self]
)

// MARK: Landing Pages

drop.get { _ in try drop.view.make("welcome") }

// MARK: /todos/

//drop.grouped(TodoURLMiddleware()).resource("todos", TodoController())
drop.grouped(ProductMiddleware()).resource("products", ProductController())


// MARK: Serve

drop.run()
