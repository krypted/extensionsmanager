//
//  ExtensionStore.swift
//  Panagram
//
//  Created by Charles Edge on 20/12/2022.
//

import Foundation

class ExtensionStore {
    
    private let requestModel: RequestModel
    
    init(requestModel: RequestModel) {
        self.requestModel = requestModel
    }
    
    // MARK: - Type
    enum ExtensionType: String {
        case network
        case system
        case thirdparty
        case apple
    }
    
    enum Query: String, CaseIterable {
        case plugin = "pluginkit -mvv"
        case systemExtension = "systemextensionsctl list"
        case chrome = "find ~/Library/Application\\ Support/Google/Chrome/Default/Extensions -type f -name \"manifest.json\" -print0 | xargs -I {} -0 grep \'\"name\\|version\\|author\"\' \"{}\" | uniq"
        case microsoftEdge = "find ~/Library/Application\\ Support/Microsoft\\ Edge/Default/Extensions -type f -name \"manifest.json\" -print0 | xargs -I {} -0 grep \'\"name\\|version\\|autor\":\' \"{}\" | uniq"
        case firefox = "find ~/Library/Application\\ Support/Firefox/Profiles/ -type f -name \"extensions.json\" -print0 | xargs -I {} -0 grep \'\' \"{}\" | uniq"
    }
    
    struct Response {
        let query: String
        let data: String
    }
    
    // MARK: - Plugins
    private func getThirdpartyExtensions() -> Result<[Extension],Error> {
        getAllPlugins().map{$0.filter{$0.vendor != "Apple"}}
    }
    
    private func getAllPlugins() -> Result<[Extension],Error> {
        let pluginResult: Result<Plugins,Error> = requestModel.runQuery(Query.plugin.rawValue)
        return pluginResult.map{$0.list}
    }
    
    // MARK: - System Extensions
    private func getAllSystemExtensions() -> Result<SystemExtensions,Error>{
        requestModel.runQuery(Query.systemExtension.rawValue)
    }
    
    private func getNetworkExtensions() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{$0.network}
    }
    
    private func getOtherExtensions() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{$0.others}
    }
    
    private func getSystemExtensionsUnloaded() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{ items in
            let all = items.network + items.others
            return all.filter{!$0.status}
        }
    }
    
    // MARK: Browser Extensions
    func getChromeExtensions() -> Result<[Extension],Error> {
        let result: Result<BrowserExtension,Error> = requestModel.runQuery(Query.chrome.rawValue)
        return result.map{ $0.list.map { item in
            item.type = "Google Chrome"
            return item
        }}
    }
    
    func getMicrosoftEdgeExtensions() -> Result<[Extension],Error> {
        let result: Result<BrowserExtension,Error> = requestModel.runQuery(Query.microsoftEdge.rawValue)
        return result.map{ $0.list.map { item in
            item.type = "MicrosoftEdge Extension"
            return item
        }}
    }
    
    func getFirefoxExtensions() -> Result<[Extension],Error> {
        let result: Result<String,Error> = requestModel.getData(query: Query.firefox.rawValue)
        switch result {
        case .success(let rawData):
            do {
                let data = rawData.trimmingCharacters(in: .whitespacesAndNewlines).data(using: .utf8) ?? Data()
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String:AnyObject]
                let jsonData = try JSONSerialization.data(withJSONObject: json ?? [:], options: .prettyPrinted)
                let firefoxExtensions = try JSONDecoder().decode(Firefox.self, from: jsonData)
                let extensions = (firefoxExtensions.addons ?? []).map {
                    let item = Extension()
                    item.name = $0.name
                    item.parentName = $0.vendor
                    item.type = "Firefox Extension"
                    item.status = $0.active
                    item.path = $0.path
                    item.version = $0.version
                    return item
                }
                return .success(extensions)
            } catch {
                print(error)
                return .success([])
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - All
    private func getAllExtensions() -> Result<[Extension],Error> {
        
        var result = [Extension]()
    
        let systemExtensions = getAllSystemExtensions().map{ $0.network + $0.others }
        for extensionsResponse in [getAllPlugins(), systemExtensions, getChromeExtensions(), getMicrosoftEdgeExtensions(), getFirefoxExtensions()] {
            switch extensionsResponse {
            case.success(let response):
                result.append(contentsOf: response)
            case .failure(let error):
                return .failure(error)
            }
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
        let empty = Result<[Extension], Error>.success([])
        let result = [filter.thirdparty ? getThirdpartyExtensions() : empty,
                      filter.network ? getNetworkExtensions() : empty,
                      filter.system ? getOtherExtensions() : empty,
                      filter.unloaded ? getSystemExtensionsUnloaded() : empty,
                      filter.googleChrome ? getChromeExtensions() : empty,
                      filter.microsoftEdge ? getMicrosoftEdgeExtensions() : empty,
                      filter.fireFox ? getFirefoxExtensions() : empty]
        
        for extensionsResponse in result {
            switch extensionsResponse {
            case.success(let response):
                extensionList.append(contentsOf: response)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        // save for later use when user only change search text
        self.extensionsList = extensionList
        
        return .success(filterExtensions(query: query, sort: sort, extensions: extensionsList))
    }
    
    // MARK: - Raw
    func getRawData() -> Result<String,Error> {
        
        var result = ""
        
        for dataResponse in Query.allCases.map({ requestModel.getData(query: $0.rawValue)}) {
            switch dataResponse {
            case .success(let response):
                let prefix = result.isEmpty ? "" : "\n"
                result.append("\(prefix)"+response)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return .success(result)
    }
}
