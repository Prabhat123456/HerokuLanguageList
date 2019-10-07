import FluentPostgreSQL
import Vapor

final class LanguageSet: Codable{
    var id: Int?
    var fromLanguage: String
    var toLanguage: String
    init(fromLanguage: String,toLanguage: String) {
        self.fromLanguage = fromLanguage
        self.toLanguage = toLanguage
    }
}


extension LanguageSet: PostgreSQLModel{}
extension LanguageSet: Content{}
extension LanguageSet: Migration{}
