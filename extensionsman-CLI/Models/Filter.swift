//
//  Filter.swift
//
//  Created by Charles Edge on 20/12/2022.
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
