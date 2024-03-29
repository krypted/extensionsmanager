//
//  ConsoleIO.swift
//
//  Created by Charles Edge on 19/12/2022.
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
        writeMessage("\(executableName) -thirdparty to show thirdparty extensions")
        writeMessage("or")
        writeMessage("\(executableName) -n to show network extensions")
        writeMessage("or")
        writeMessage("\(executableName) -s to show system extensions except network extensions")
        writeMessage("or")
        writeMessage("\(executableName) -u to show unloaded system extensions")
        writeMessage("or")
        writeMessage("\(executableName) -c to show google chrome extensions")
        writeMessage("or")
        writeMessage("\(executableName) -e to show microsoft edge extensions")
        writeMessage("or")
        writeMessage("\(executableName) -f to show firefox extensions")
        writeMessage("or")
        writeMessage("\(executableName) -raw to show unformatted result")
        writeMessage("or")
        writeMessage("\(executableName) -h to show usage information")
    }
}
