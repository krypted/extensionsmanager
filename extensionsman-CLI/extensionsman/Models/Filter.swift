//
//  Filter.swift
//  Panagram
//
//  Created by Charles Edge on 05/15/2023.
//

import Foundation

protocol Filter {
    func isValid(_ value: String) -> Bool
}

class AppleExtensionFilter: Filter {
    
    func isValid(_ value: String) -> Bool {
        value.starts(with: "com.apple") && !value.isEmpty
    }
}

class ThirdPartyExtensionFilter: Filter {
    
    func isValid(_ value: String) -> Bool {
        !value.starts(with: "com.apple") && !value.isEmpty
    }
}
