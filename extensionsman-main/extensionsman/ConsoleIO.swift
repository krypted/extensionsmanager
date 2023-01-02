//
//  ConsoleIO.swift
//
// Created by Charles Edge
//

import Foundation
class ConsoleIO {
    
    enum OutputType {
        case error
        case standard
    }
    
    func writeMessage(_ message: String, to: OutputType = .standard) {
        switch to {
        case .standard:
            print(message)
        case .error:
            fputs("Error: \(message)\n", stderr)
        }
    }
    
    func printUsage() {
        let executableName =  (CommandLine.arguments[0] as NSString).lastPathComponent
        writeMessage("usage:")
        writeMessage("\(executableName) -all to show all extensions")
        writeMessage("or")
        writeMessage("\(executableName) to show thirdparty extensions")
        writeMessage("or")
        writeMessage("\(executableName) -h to show usage information")
    }
}
