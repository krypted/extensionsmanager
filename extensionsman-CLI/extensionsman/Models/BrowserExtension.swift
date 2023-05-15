import Foundation

struct BrowserExtension: Parseable {
    
    let list: [Extension]
    
    init(string: String) {
        list = BrowserExtensionParser.parse(string: string)
    }
}

class BrowserExtensionParser {

    static func parse(string: String) -> [Extension] {
        
        let lines = string.replacingOccurrences(of: "\n", with: ",").components(separatedBy: ",").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter{!$0.isEmpty}
        
        var items = [Extension]()
        var item = Extension()
        // status
        // path
        
        for line in lines where !line.isEmpty {
            // tells type of extensions
            if line.contains("\"name\":") {
                if !item.name.isEmpty {
                    items.append(item)
                }
                item = Extension()
                item.status = true
                item.name = getValue(from: line, key: "name")
            } else if line.contains("\"author\":") {
                item.vendor = getValue(from: line, key: "author")
            } else if line.contains("\"version\":") {
                item.version = getValue(from: line, key: "version")
            }
        }
        
        if !item.name.isEmpty {
            items.append(item)
        }
        
        return items
    }
    
    static private func getValue(from string: String, key: String) -> String {
        return string.replacingOccurrences(of: "\"\(key)\":", with: "").replacingOccurrences(of: "\"", with: "")
            .replacingOccurrences(of: ",", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
