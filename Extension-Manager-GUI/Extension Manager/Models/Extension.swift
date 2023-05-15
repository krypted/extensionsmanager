//
//  Extensions.swift
//  Extension Manager
//
//  Created by Charles Edge on 05/15/2023.
//

import Foundation

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
    
    func getStatusDescription() -> String {
        return status ? "Installed" : "Not Installed"
    }
    
    func getVersionNo() -> Double {
        let components = version.components(separatedBy: ".")
        if components.count > 2 {
            return Double("\(components[0]).\(components[1])") ?? 0
        }else {
            return Double(version) ?? 0
        }
    }
}
