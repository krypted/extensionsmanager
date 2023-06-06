//
//  Plugings.swift
//  Extension Manager
//
//  Created by Charles Edge on 15/05/2023.
//

import Foundation

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
