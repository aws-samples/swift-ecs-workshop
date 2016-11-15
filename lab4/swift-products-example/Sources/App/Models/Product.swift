import Vapor
import Fluent

// MARK: Model

struct Product: Model {
    var id: Node?

    var name: String?
    var description: String?
    var price: Double?
	  var count: Int?
	  var image_url_1: String?
	  var image_url_2: String?

    // used by fluent internally
    var exists: Bool = false
}

// MARK: NodeConvertible

extension Product: NodeConvertible {
    init(node: Node, in context: Context) throws {
        id = node["id"]
        name = node["name"]?.string
        description = node["image"]?.string
        price = node["price"]?.double ?? 0
    	  count = node["count"]?.int ?? 0
    	  image_url_1 = node["image_url_1"]?.string
    	  image_url_2 = node["image_url_2"]?.string
    }

    func makeNode(context: Context) throws -> Node {
        // model won't always have value to allow proper merges,
        // database defaults to false
        return try Node.init(node:
            [
                "id": id,
                "name": name,
                "description" : description,
                "price" : price,
            	  "count" : count,
            	  "image_url_1" : image_url_1,
            	  "image_url_2" : image_url_2

            ]
        )
    }
}

// MARK: Database Preparations

extension Product: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create("products") { users in
            users.id()
            users.string("name")
            users.string("description")
            users.double("price")
            users.int("count")
            users.string("image_url_1")
            users.string("image_url_2")
        }
    }

    static func revert(_ database: Database) throws {
        fatalError("unimplemented \(#function)")
    }
}

// MARK: Merge

extension Product {
    mutating func merge(updates: Product) {
        id = updates.id ?? id
        name = updates.name ?? name
        description = updates.description ?? description
        price = updates.price ?? price
        count = updates.count ?? count
        image_url_1 = updates.image_url_1 ?? image_url_1
        image_url_2 = updates.image_url_2 ?? image_url_2
    }
}
