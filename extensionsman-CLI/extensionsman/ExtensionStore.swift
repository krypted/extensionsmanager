//
//  ExtensionStore.swift
//
//  Charles Edge
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
        case plugin = "pluginkit -m"
        case systemExtension = "systemextensionsctl list"
        case systemExtensionUnloaded = "systemextensionsctl list | grep 'activated disabled' | awk '{print $4}'"
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
    func getThirdpartyExtensions() -> Result<[String],Error> {
        getAllPlugins(filter: ThirdPartyExtensionFilter())
    }
    
    private func getAllPlugins(filter: Filter?) -> Result<[String],Error> {
        let pluginResult: Result<Plugins,Error> = runQuery(Query.plugin.rawValue)
        return pluginResult.map{ plugins in
            if let filter  = filter {
                return plugins.list.filter{filter.isValid($0)}
            }else {
                return plugins.list
            }
        }
    }
    
    // MARK: - System Extensions
    
    private func getSystemExtensions() -> Result<SystemExtensions,Error>{
        runQuery(Query.systemExtension.rawValue)
    }
    
    func getNetworkExtensions() -> Result<[String],Error> {
        getSystemExtensions().map{$0.network}
    }
    
    func getSystemExtensionsUnloaded() -> Result<[String],Error>{
        let result: Result<SystemExtensionsUnloaded,Error> = runQuery(Query.systemExtensionUnloaded.rawValue)
        return result.map{$0.list}
    }
    
    func getOtherExtensions() -> Result<[String],Error> {
        getSystemExtensions().map{$0.others}
    }
    
    // MARK: - All
    func getAllExtensions() -> Result<[String],Error> {
        var result = [String]()
    
        switch getAllPlugins(filter: nil) {
        case .success(let response):
            result.append(contentsOf: response)
        case .failure(let error):
            return .failure(error)
        }
        
        switch getSystemExtensions() {
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
        task.arguments = ["-c", command]
        task.executableURL = URL(fileURLWithPath: "/bin/zsh") //<--updated
        task.standardInput = nil

        try task.run() //<--updated
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
