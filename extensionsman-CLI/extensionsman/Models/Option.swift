//
//  Option.swift
//  extensionsman
//
//  Created by Charles Edge on 05/15/2023.
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
    case googleChrome = "c"
    case microsoftEdge = "e"
    case firefox = "f"
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
        case "c":
            self = .googleChrome
        case "e":
            self = .microsoftEdge
        case "f":
            self = .firefox
        case "h":
            self = .help
        default:
            self = .unknown
        }
    }
}
