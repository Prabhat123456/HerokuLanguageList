import FluentPostgreSQL
import Vapor

final class WordCollection: Codable{
    var id: Int?
    var languageWord: String
    var key : Int
    init(withLanguage languageWord: String, WithRound round:Int, andKey key:Int) {
        self.languageWord = languageWord
        self.key = key
    }
}


extension WordCollection: PostgreSQLModel{}
extension WordCollection: Content{}
extension WordCollection: Migration{}
