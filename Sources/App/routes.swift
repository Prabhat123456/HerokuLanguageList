import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let wordController = WordController()
     try router.register(collection: wordController)
   
}
