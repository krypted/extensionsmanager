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
    private func getThirdpartyExtensions() -> Result<[Extension],Error> {
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
    
    private func getNetworkExtensions() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{$0.network}
    }
    
    private func getSystemExtensionsUnloaded() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{ items in
            let all = items.network + items.others
            return all.filter{!$0.status}
        }
    }
    
    private func getOtherExtensions() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{$0.others}
    }
    
    // MARK: - All
    private func getAllExtensions() -> Result<[Extension],Error> {
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
    
    // MARK: Filter Data
    private var extensionsList = [Extension]()
    private var query = ""
    private var sort = Sort(type: .name, acending: true)
    
    func changeQuery(query: String) -> [Extension] {
        self.query = query
        return filterExtensions(query: query, sort: sort, extensions: extensionsList)
    }
    
    func changeSorting(sort: Sort) -> [Extension] {
        self.sort = sort
        return filterExtensions(query: query, sort: sort, extensions: extensionsList)
    }
    
    private func filterExtensions(query: String, sort: Sort, extensions: [Extension]) -> [Extension] {
        var list = extensions
        if !query.isEmpty {
            list = list.filter{$0.name.lowercased().starts(with: query.lowercased())}
        }
        
        list = sortExtensions(sort: sort, extensions: list)
        return list
    }
    
    private func sortExtensions(sort: Sort, extensions: [Extension]) -> [Extension] {
        var result = extensions
        let isSorted: (String,String)->Bool = { value1, value2 -> Bool in
            sort.acending ? value1 < value2 : value1 > value2
        }
        
        switch sort.type {
        case .name:
            result = result.sorted(by: { e1, e2 in
                isSorted(e1.name, e2.name)
            })
        case .vendor:
            result = result.sorted(by: { e1, e2 in
                isSorted(e1.vendor, e2.vendor)
            })
        case .type:
            result = result.sorted(by: { e1, e2 in
                isSorted(e1.type, e2.type)
            })
        case .status:
            result = result.sorted(by: { e1, e2 in
                isSorted(e1.getStatusDescription(), e2.getStatusDescription())
            })
        case .path:
            result = result.sorted(by: { e1, e2 in
                isSorted(e1.path, e2.path)
            })
        case .version:
            result = result.sorted(by: { e1, e2 in
                sort.acending ? e1.getVersionNo() < e2.getVersionNo() : e1.getVersionNo() > e2.getVersionNo()
            })
        case .sdk:
            result = result.sorted(by: { e1, e2 in
                isSorted(e1.sdk, e2.sdk)
            })
        }
        
        return result
    }
    
    func getExtensions(filter: Filter, query: String, sort: Sort) -> Result<[Extension], Error> {
        
        self.query = query
        self.sort = sort
        
        guard !filter.all else {
            let result = getAllExtensions()
            
            // save for later use when user only change search text
            self.extensionsList = (try? result.get()) ?? []
            
            return result.map{ filterExtensions(query: query, sort: sort, extensions: $0) }
        }
        
        var extensionList = [Extension]()
        
        if filter.thirdparty {
            switch getThirdpartyExtensions() {
            case .success(let items):
                extensionList.append(contentsOf: items)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        if filter.network {
            switch getNetworkExtensions() {
            case .success(let items):
                extensionList.append(contentsOf: items)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        if filter.system {
            switch getOtherExtensions() {
            case .success(let items):
                extensionList.append(contentsOf: items)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        
        if filter.unloaded {
            switch getSystemExtensionsUnloaded() {
            case .success(let items):
                extensionList.append(contentsOf: items)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        // save for later use when user only change search text
        self.extensionsList = extensionList
        
        return .success(filterExtensions(query: query, sort: sort, extensions: extensionsList))
    }
    
    // MARK: - Raw
    private func getRawData() -> Result<String,Error> {
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
