import FluentPostgreSQL
import Vapor

final class LanguageSupported: Codable{
    var id: Int?
    var languageSupported: String
    init(languageSupported: String) {
        self.languageSupported = languageSupported
    }
}


extension LanguageSupported: PostgreSQLModel{}
extension LanguageSupported: Content{}
extension LanguageSupported: Migration{}
extension LanguageSupported: Parameter{}
