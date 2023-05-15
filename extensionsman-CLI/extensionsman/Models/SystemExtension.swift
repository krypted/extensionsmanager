import Foundation

struct SystemExtensions: Parseable {

    let network: [Extension]
    let others: [Extension]
    
    init(string: String) {
        let data = SystemExtensionParser.parse(string: string)
        network = data.network
        others = data.others
    }
    
    init(network: [Extension], others: [Extension]) {
        self.network = network
        self.others = others
    }
}

struct SystemExtensionsUnloaded: Parseable {

    let list: [String]
    
    init(string: String) {
        list = string.components(separatedBy: "\n").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter{!$0.isEmpty}
    }
}

class SystemExtensionParser {

    static func parse(string: String) -> SystemExtensions {
        
        let lines = string.components(separatedBy: "\n").dropFirst().map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
    
        var otherItems = [Extension]()
        var networkItems = [Extension]()
        var isNetworkItems = false
        
        for line in lines where !line.isEmpty {
            // tells type of extensions
            if line.starts(with: "---") {
                isNetworkItems = line.contains("com.apple.system_extension.network_extension")
            }
            // tells column names
            else if line.contains("bundleID (version)") {
                continue
            }
            // network item
            else {
                let columns = line.components(separatedBy: "\t")
                let extensionItem = Extension()
                let bundleInfo = columns.getItemOrEmpty(at: 3)
                let bundleComponents = bundleInfo.components(separatedBy: "(")
                extensionItem.bundle = bundleComponents.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                let versionInfo = (bundleComponents.last ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
                let versionComponents = versionInfo.components(separatedBy: "/")
                extensionItem.version = versionComponents.isEmpty ? versionInfo : (versionComponents.first ?? "")
                extensionItem.name = columns.getItemOrEmpty(at: 4)
                extensionItem.type = isNetworkItems ? "Network Extension" : "System Extension"
                extensionItem.status = columns.getItemOrEmpty(at: 5).contains("enabled")
                isNetworkItems ? networkItems.append(extensionItem) : otherItems.append(extensionItem)
            }
        }
    
        return .init(network: networkItems, others: otherItems)
    }
}
