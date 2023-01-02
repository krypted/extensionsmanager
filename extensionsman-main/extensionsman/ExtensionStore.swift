//
//  ExtensionStore.swift
//
// Created by Charles Edge
//

import Foundation

class ExtensionStore {
    
    func getExtensionsRaw() -> Result<String,Error> {
        do {
            let data = try safeShell("pluginkit -m")
            return .success(data)
        }catch {
            return .failure(error)
        }
    }
    
    func getAllExtensions() -> Result<[String],Error> {
        getExtensionsRaw().map { data in
            data.components(separatedBy: "\n").map{
                $0.replacingOccurrences(of: "+", with: "")
                .replacingOccurrences(of: "-", with: "")
                .replacingOccurrences(of: ". com", with: "com")
                .replacingOccurrences(of: ".com", with: "")
                .replacingOccurrences(of: "H.", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        /*
        do {
            let data = try safeShell("pluginkit -m")
            let extensions = data.components(separatedBy: "\n").map{
                $0.replacingOccurrences(of: "+", with: "")
                .replacingOccurrences(of: "-", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            }
            
            return .success(extensions)
        }catch {
            return .failure(error)
        }*/
    }
    
    func getExtensionsWith(filter: Filter?) -> Result<[String],Error> {
        if let filter  = filter {
            return getAllExtensions().map { extensions in
                extensions.filter{filter.isValid($0)}
            }
        }else {
            return getAllExtensions()
        }
    }
    
    @discardableResult func safeShell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
        task.standardInput = nil

        try task.run() //<--updated
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
