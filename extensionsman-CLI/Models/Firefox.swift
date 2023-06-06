import Foundation

class Firefox: Decodable {
    let addons: [FirefoxItem]?
}

class FirefoxItem: Decodable {
    private let id: String
    private let defaultLocale: DefaultLocale?
    private let location: String
    let version: String
    let path: String
    let active: Bool
    var name: String { defaultLocale?.name ?? "" }
    var vendor: String { defaultLocale?.homepageURL ??  id }

    enum CodingKeys: CodingKey {
        case id
        case defaultLocale
        case location
        case version
        case path
        case active
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? ""
        self.defaultLocale = try container.decodeIfPresent(DefaultLocale.self, forKey: .defaultLocale)
        self.location = try container.decodeIfPresent(String.self, forKey: .location) ?? ""
        self.version = try container.decodeIfPresent(String.self, forKey: .version) ?? ""
        self.path = try container.decodeIfPresent(String.self, forKey: .path) ?? ""
        self.active = try container.decodeIfPresent(Bool.self, forKey: .active) ?? false
    }
    
}

class DefaultLocale: Decodable {
    let name: String?
    let homepageURL: String?
}
