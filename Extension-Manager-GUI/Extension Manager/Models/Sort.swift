import Foundation

struct Sort {
    let type: SortType
    let acending: Bool
}

enum SortType {
    case name
    case vendor
    case type
    case path
    case status
    case version
    case sdk
    
    init?(value: String) {
        switch value {
        case "name":
            self = .name
        case "vendor":
            self = .vendor
        case "type":
            self = .type
        case "status":
            self = .status
        case "path":
            self = .path
        case "version":
            self = .version
        case "sdk":
            self = .sdk
        default:
            return nil
        }
    }
}
