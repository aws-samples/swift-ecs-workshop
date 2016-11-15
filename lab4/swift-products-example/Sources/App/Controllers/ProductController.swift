import HTTP
import Vapor

final class ProductController: ResourceRepresentable {
    func index(request: Request) throws -> ResponseRepresentable {
        return try Product.all().makeNode().converted(to: JSON.self)
    }

    func create(request: Request) throws -> ResponseRepresentable {
        var product = try request.product()
        try product.save()
        return product
    }

    func show(request: Request, product: Product) throws -> ResponseRepresentable {
        return product
    }

    func delete(request: Request, product: Product) throws -> ResponseRepresentable {
        try product.delete()
        return JSON([:])
    }

    func clear(request: Request) throws -> ResponseRepresentable {
        try Product.deleteAll()
        return JSON([])
    }

    func update(request: Request, product: Product) throws -> ResponseRepresentable {
        let new = try request.product()
        var product = product
        product.merge(updates: new)
        try product.save()
        return product
    }

    func replace(request: Request, product: Product) throws -> ResponseRepresentable {
        try product.delete()
        return try create(request: request)
    }

    func makeResource() -> Resource<Product> {
        return Resource(
            index: index,
            store: create,
            show: show,
            replace: replace,
            modify: update,
            destroy: delete,
            clear: clear
        )
    }
}

extension Request {
    func product() throws -> Product {
        guard let json = json else { throw Abort.badRequest }
        return try Product(node: json)
    }
}
