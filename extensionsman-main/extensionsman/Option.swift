//
//  Option.swift
//  extensionsman
//
// Created by Charles Edge
//

import Foundation

enum Option: String {
    case all = "all"
    case raw = "raw"
    case help = "h"
    case unknown
    
    init(value: String) {
        switch value {
        case "all":
            self = .all
        case "raw":
            self = .raw
        case "h":
            self = .help
        default:
            self = .unknown
        }
    }
}
