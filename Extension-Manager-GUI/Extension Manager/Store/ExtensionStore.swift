//
//  ExtensionStore.swift
//
//

import Foundation

//kextstat  kernal extensions

class ExtensionStore {
    
    // MARK: - Type
    enum ExtensionType: String {
        case network
        case system
        case thirdparty
        case apple
    }
    
    enum Query: String {
        case plugin = "pluginkit -mvv"
        case systemExtension = "systemextensionsctl list"
    }
    
    struct Response {
        let query: String
        let data: String
    }
    
    // MARK: - Data
    private func getData(query: String) -> Result<String,Error> {
        do {
            let data = try safeShell(query)
            return .success(data)
        }catch {
            return .failure(error)
        }
    }
    
    private func runQuery<T>(_ query: String) -> Result<T,Error> where T: Parseable {
        getData(query: query).map{ T(string: $0) }
    }
    
    // MARK: - Plugins
    func getThirdpartyExtensions() -> Result<[Extension],Error> {
        getAllPlugins().map{$0.filter{$0.vendor != "Apple"}}
    }
    
    private func getAllPlugins() -> Result<[Extension],Error> {
        let pluginResult: Result<Plugins,Error> = runQuery(Query.plugin.rawValue)
        return pluginResult.map{$0.list}
    }
    
    // MARK: - System Extensions
    private func getAllSystemExtensions() -> Result<SystemExtensions,Error>{
        runQuery(Query.systemExtension.rawValue)
    }
    
    func getNetworkExtensions() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{$0.network}
    }
    
    func getSystemExtensionsUnloaded() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{ items in
            let all = items.network + items.others
            return all.filter{!$0.status}
        }
    }
    
    func getOtherExtensions() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{$0.others}
    }
    
    // MARK: - All
    func getAllExtensions() -> Result<[Extension],Error> {
        var result = [Extension]()
    
        switch getAllPlugins() {
        case .success(let response):
            result.append(contentsOf: response)
        case .failure(let error):
            return .failure(error)
        }
        
        switch getAllSystemExtensions() {
        case .success(let response):
            result.append(contentsOf: response.network)
            result.append(contentsOf: response.others)
        case .failure(let error):
            return .failure(error)
        }
        
        return .success(result)
    }
    
    // MARK: - Raw
    func getRawData() -> Result<String,Error> {
        var result = ""
        switch getData(query: Query.plugin.rawValue) {
        case .success(let response):
            result = response
        case .failure(let error):
            return .failure(error)
        }
        
        switch getData(query: Query.systemExtension.rawValue) {
        case .success(let response):
            result.append("\n"+response)
        case .failure(let error):
            return .failure(error)
        }
        
        return .success(result)
    }
    
    
    @discardableResult func safeShell(_ command: String) throws -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
//        task.arguments = ["-c", command]
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
//        task.executableURL = URL(fileURLWithPath: "/bin/bash") //<--updated
//        task.executableURL = URL(fileURLWithPath: "/usr/bin/env") //<--updated
        task.standardInput = nil

        try task.run() //<--updated
//        task.launch()
        
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
    
        return output
    }
}
