//
//  Models.swift
//  extensionsman
//
//

import Foundation

enum Option: String {
    case raw = "raw"
    case all = "all"
    case thirdparty = "thirdparty"
    case network = "n"
    case system = "s"
    case systemUnloaded = "u"
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "raw":
            self = .raw
        case "all":
            self = .all
        case "thirdparty":
            self = .thirdparty
        case "n":
            self = .network
        case "s":
            self = .system
        case "u":
            self = .systemUnloaded
        case "h":
            self = .help
        default:
            self = .unknown
        }
    }
}

class Extension {
    var name: String
    var status: Bool
    var path: String
    var version: String
    var sdk: String
    var bundle: String
    var parentName: String
    var type: String
    var vendor: String {
        if bundle.contains("com.apple"){
            return "Apple"
        } else if !parentName.isEmpty {
            return parentName
        } else {
            return bundle.components(separatedBy: ".").getItemOrEmpty(at: 1)
        }
    }
    
    init() {
        name = ""
        status = false
        path = ""
        version = ""
        sdk = ""
        bundle = ""
        parentName = ""
        type = ""
    }
}

protocol Parseable {
    init( string: String)
}

struct Plugins: Parseable {
    let list: [Extension]
    
    init(string: String) {
        list = PluginParser.parse(string: string)
    }
}

class PluginParser {
    
    static func parse(string: String) -> [Extension] {
        
        let items = string.components(separatedBy: "\n").dropLast()
        
        var extensionList = [Extension]()
        var extensionItem = Extension()
        extensionItem.type = "App Extension"
        var newItem = true
        
        for item in items {
            if item.isEmpty {
                extensionList.append(extensionItem)
                extensionItem = Extension()
                extensionItem.type = "App Extension"
                newItem = true
                continue
            }
            
            if newItem {
                extensionItem.status = !item.contains("-")
                let bundleComponents = item.replacingOccurrences(of: "+", with: "").replacingOccurrences(of: "-", with: "").components(separatedBy: "(")
                extensionItem.version = bundleComponents.last?.replacingOccurrences(of: ")", with: "").trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                extensionItem.bundle = bundleComponents.first?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                
            }else if item.contains("Path"){
                extensionItem.path = item.replacingOccurrences(of: "Path = ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }else if item.contains("SDK") {
                extensionItem.sdk = item.replacingOccurrences(of: "SDK = ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }else if item.contains("Display Name") {
                extensionItem.name = item.replacingOccurrences(of: "Display Name = ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }else if item.contains("Parent Name") {
                extensionItem.parentName = item.replacingOccurrences(of: "Parent Name = ", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            newItem = false
            
        }
        
        return extensionList
    }
}

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

struct SystemExtensionsUnloaded: Parseable {

    let list: [String]
    
    init(string: String) {
        list = string.components(separatedBy: "\n").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter{!$0.isEmpty}
    }
}
