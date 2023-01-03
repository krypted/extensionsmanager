//
//  Panagram.swift
//
//  Charles Edge
//

import Foundation

class ExtensionMan {
    
    let consoleIO = ConsoleIO()
    let store = ExtensionStore()
    
    func staticMode() {
        
        guard CommandLine.arguments.count > 1 else {
            consoleIO.printUsage()
            return
        }
    
        let arguments = CommandLine.arguments[1].components(separatedBy: " ")
        let options = arguments.filter{$0.first == "-"}.map{$0.replacingOccurrences(of: "-", with: "")}

        let (option,value) = getOption(options[0])
        
        switch option {
        case .raw:
            let result = store.getRawData().map{[$0]}
            show(result: result)
        case .all:
            let result = store.getAllExtensions()
            show(result: result)
        case .thirdparty:
            let result = store.getThirdpartyExtensions()
            show(result: result)
        case .network:
            let result = store.getNetworkExtensions()
            show(result: result)
        case .system:
            let result = store.getOtherExtensions()
            show(result: result)
        case .systemUnloaded:
            let result = store.getSystemExtensionsUnloaded()
            show(result: result)
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
            consoleIO.writeMessage(message.isEmpty ? "0 Items" : message)
        case .failure(let error):
            consoleIO.writeMessage(error.localizedDescription, to: .error)
        }
    }

    func getOption(_ option: String) -> (Option,String) {
        return (Option(value: option), option)
    }
}


