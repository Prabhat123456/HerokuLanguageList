import Vapor
import Fluent

struct WordController: RouteCollection {
    
    func boot(router: Router) throws {
        //Query For Langugae Supported
        let languageSupportedRoute = router.grouped("api","languageSupported")
        languageSupportedRoute.get(use: getHandlerSupportedLangugae)
        languageSupportedRoute.post(LanguageSupported.self,use: createHandlerSupportedLangugae)
        languageSupportedRoute.put(LanguageSupported.parameter, use: updateHandlerLanguageSupported)
        languageSupportedRoute.delete(LanguageSupported.parameter, use: deleteHandlerSupportedLangugae)
        
        // Query For WordListTable
        let wordRoute = router.grouped("api","word")
        wordRoute.get(use: getHandlerWordModel)
        wordRoute.post(WordModel.self,use: createHandlerWordModel)
        wordRoute.put(WordModel.parameter, use: updateHandlerWordModel)
        wordRoute.delete(WordModel.parameter, use: deleteHandlerWordModel)
        
        // Query for Mapping
        let pairLanguage = router.grouped("apipair")
        pairLanguage.get("search",use: getHandlerLanguageSet)
        
    }
    
    func getHandlerSupportedLangugae(_ req:Request) throws -> Future<[LanguageSupported]>{
        return LanguageSupported.query(on: req).all()
    }
    
    func createHandlerSupportedLangugae(_ req:Request, languageSupported: LanguageSupported) throws -> Future<LanguageSupported>{
        return languageSupported.save(on: req)
    }
    
    func deleteHandlerSupportedLangugae(_ req:Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(LanguageSupported.self).flatMap(to: HTTPStatus.self){ languageSupported in
            return languageSupported.delete(on: req).transform(to: .noContent)
        }
    }
    
    
    func updateHandlerLanguageSupported(_ req:Request) throws -> Future<LanguageSupported>{
        return try flatMap(to:LanguageSupported.self, req.parameters.next(LanguageSupported.self),req.content.decode(LanguageSupported.self)){ languageSupported , updatedLanguageSupported in
            languageSupported.languageSupported = updatedLanguageSupported.languageSupported
            
            return languageSupported.save(on:req)
        }
    }
    
    func getHandlerWordModel(_ req:Request) throws -> Future<[WordModel]>{
        return WordModel.query(on: req).all()
    }
    
    func createHandlerWordModel(_ req:Request, wordModel: WordModel) throws -> Future<WordModel>{
        return wordModel.save(on: req)
    }
    
    func updateHandlerWordModel(_ req:Request) throws -> Future<WordModel>{
        return try flatMap(to:WordModel.self, req.parameters.next(WordModel.self),req.content.decode(WordModel.self)){ word , updatedWord in
            word.languageName = updatedWord.languageName
            word.round = updatedWord.round
            word.words = updatedWord.words
            return word.save(on:req)
        }
    }
    
    func deleteHandlerWordModel(_ req:Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(WordModel.self).flatMap(to: HTTPStatus.self){ wordModel in
            return wordModel.delete(on: req).transform(to: .noContent)
        }
    }
    
    func getHandlerLanguageSet(_ req:Request) throws -> Future<[LanguageSet]>{
        guard let fromLanguage = req.query[String.self,at:"from"],
            let toLanguage = req.query[String.self,at:"to"],
            let roundNo = req.query[Int.self,at:"round"]
            else{
                throw Abort(.badRequest)
        }
        var fromWordCollections = [WordCollection]()
        var toWordCollections = [WordCollection]()
        let fromModel =  WordModel.query(on: req).filter(\.languageName, .equal, fromLanguage).filter(\.round, .equal, roundNo).all()
        let toModel =  WordModel.query(on: req).filter(\.languageName, .equal, toLanguage).filter(\.round, .equal, roundNo).all()
        let fromWordCollectionFuture = fromModel.map { (wordModel) -> ([WordCollection]) in
            for item in wordModel{
                fromWordCollections.append(contentsOf: item.words)
            }
            return fromWordCollections
        }
        let toWordCollectionFuture = toModel.map { (wordModel) -> ([WordCollection]) in
            for item in wordModel{
                toWordCollections.append(contentsOf: item.words)
            }
            return toWordCollections
        }
        var languageSetList = [LanguageSet]()
        fromWordCollectionFuture.whenComplete {
            toWordCollectionFuture.whenComplete {
                var sortedFrom = fromWordCollections.sorted(by: { $0.key < $1.key })
                var sortedTo =  toWordCollections.sorted(by: {$0.key < $1.key })
                for index in sortedFrom.enumerated() {
                    let fromValue = sortedFrom[index.offset]
                    let toValue =  sortedTo[index.offset]
                    let languageSet = LanguageSet(fromLanguage: fromValue.languageWord, toLanguage: toValue.languageWord)
                    languageSetList.append(languageSet)
                }
            }
        }
        
        let languageSet = LanguageSet.query(on: req).all()
        return languageSet.map{ (languageSets) -> ([LanguageSet]) in
            return languageSetList
            
        }
    }
}
