//
//  Models.swift
//
//  Charles Edge
//

import Foundation

protocol Parseable {
    init( string: String)
}

struct Plugins: Parseable {
    let list: [String]
    
    init(string: String) {
        list = PluginParser.parse(string: string)
    }
}

class PluginParser {
    
    static func parse(string: String) -> [String] {
        string.components(separatedBy: "\n").map{
            $0.replacingOccurrences(of: "+", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: ". com", with: "com")
                .replacingOccurrences(of: ".com", with: "")
                .replacingOccurrences(of: "H.", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}

struct SystemExtensions: Parseable {

    let network: [String]
    let others: [String]
    
    init(string: String) {
        let data = SystemExtensionParser.parse(string: string)
        network = data.network
        others = data.others
    }
    
    init(network: [String], others: [String]) {
        self.network = network
        self.others = others
    }
}

class SystemExtensionParser {

    static func parse(string: String) -> SystemExtensions {
//        var data = """
//3 extension(s)\n--- com.apple.system_extension.network_extension\nenabled\tactive\tteamID\tbundleID (version)\tname\t[state]\n*\t*\tAH4XFXJ7DK\tcom.fortinet.forticlient.macos.vpn.nwextension (7.0.7/0245)\tvpnprovider\t[activated enabled]\n*\t*\tAH4XFXJ7DK\tcom.fortinet.forticlient.macos.webfilter (1.6.5/1)\tFortiClientPacketFilter\t[activated enabled]\n*\t*\tMLZF7K7B5R\tat.obdev.littlesnitch.networkextension (5.5/6273)\tLittle Snitch Network Extension\t[activated enabled]\n
//"""
        let lines = string.components(separatedBy: "\n").dropFirst().map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
    
        var otherItems = [[String]]()
        var networkItems = [[String]]()
        var isNetworkItems = false
        
        for line in lines where !line.isEmpty {
            // tells type of extensions
            if line.contains("com.apple.system_extension.network_extension") {
                isNetworkItems = true
            }
            // tells column names
            else if line.contains("bundleID (version)") {
                continue
            }
            // network item
            else if isNetworkItems {
                networkItems.append(line.components(separatedBy: "\t"))
            }
            // other item
            else {
                otherItems.append(line.components(separatedBy: "\t"))
            }
        }
        let networkItemBundleIds = networkItems.map{$0.count < 3 ? "" : $0[3]}
        let otherItemBundleIds = otherItems.map{$0.count < 3 ? "" : $0[3]}
        return .init(network: networkItemBundleIds, others: otherItemBundleIds)
    }
}

struct SystemExtensionsUnloaded: Parseable {

    let list: [String]
    
    init(string: String) {
        list = string.components(separatedBy: "\n").map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}.filter{!$0.isEmpty}
    }
}

//class SystemExtensionsUnloadedParser {
//
//    static func parse(string: String) -> SystemExtensions {
//        let lines = string.components(separatedBy: "\n").dropFirst().map{$0.trimmingCharacters(in: .whitespacesAndNewlines)}
//        return .init(network: networkItemBundleIds, others: otherItemBundleIds)
//    }
//}
