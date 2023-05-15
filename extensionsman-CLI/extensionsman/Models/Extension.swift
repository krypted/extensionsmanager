import Foundation

class Extension {
    var name: String
    var vendor: String
    var status: Bool
    var path: String
    var version: String
    var sdk: String
    var bundle: String
    var parentName: String
    var type: String
    
    init() {
        name = ""
        vendor = ""
        status = false
        path = ""
        version = ""
        sdk = ""
        bundle = ""
        parentName = ""
        type = ""
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
    }
}
