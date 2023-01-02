//
//  Panagram.swift
//
// Created by Charles Edge
//

import Foundation

class ExtensionMan {
    
    let consoleIO = ConsoleIO()
    let store = ExtensionStore()
    
    func staticMode() {
        guard CommandLine.arguments.count > 1 else {
            let result = store.getExtensionsWith(filter: ThirdPartyExtensionFilter())
            show(result: result)
            return
        }
    
        
        let arguments = CommandLine.arguments[1].components(separatedBy: " ")
        let options = arguments.filter{$0.first == "-"}.map{$0.replacingOccurrences(of: "-", with: "")}

        let (option,value) = getOption(options[0])
        
        switch option {
        case .all:
            let result = store.getExtensionsWith(filter: nil)
            show(result: result)
        case .raw:
            let result = store.getExtensionsRaw()
            show(result: result.map{[$0]})
        case .help:
            consoleIO.printUsage()
        case .unknown:
            consoleIO.writeMessage("Unknown option \(value)")
            consoleIO.printUsage()
        }
    }
    
    func show(result: Result<[String],Error>) {
        switch result {
        case .success(let response):
            let message = response.joined(separator: "\n")
            consoleIO.writeMessage(message)
        case .failure(let error):
            consoleIO.writeMessage(error.localizedDescription, to: .error)
        }
    }

    func getOption(_ option: String) -> (Option,String) {
        return (Option(value: option), option)
    }
}


