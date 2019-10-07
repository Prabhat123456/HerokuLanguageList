import FluentPostgreSQL
import Vapor

final class WordModel: Codable{
    var id: Int?
    var languageName: String
    var round: Int
    var words:[WordCollection]
    
    init(withLanguage languageName: String, andWithWords words:[WordCollection] , andRound round: Int) {
        self.languageName = languageName
        self.words = words
        self.round = round
    }
}


extension WordModel: PostgreSQLModel{}
extension WordModel: Content{}
extension WordModel: Migration{}
extension WordModel: Parameter{}
