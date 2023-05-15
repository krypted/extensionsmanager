//
//  ExtensionStore.swift
//  Panagram
//
//  Created by Charles Edge on 05/15/2023.
//

import Foundation

//kextstat  kernal extensions

class ExtensionStore {
    
    let requestModel: RequestModel
    
    init(requestModel: RequestModel) {
        self.requestModel = requestModel
    }
    
    enum Query: String, CaseIterable {
        case plugin = "pluginkit -mvv"
        case systemExtension = "systemextensionsctl list"
        case chrome = "find ~/Library/Application\\ Support/Google/Chrome/Default/Extensions -type f -name \"manifest.json\" -print0 | xargs -I {} -0 grep \'\"name\\|version\\|author\"\' \"{}\" | uniq"
        case microsoftEdge = "find ~/Library/Application\\ Support/Microsoft\\ Edge/Default/Extensions -type f -name \"manifest.json\" -print0 | xargs -I {} -0 grep \'\"name\\|version\\|autor\":\' \"{}\" | uniq"
        // find ~/Library/Application\ Support/Microsoft\ Edge/Default/Extensions -type f -name "manifest.json" -print0 | xargs -I {} -0 grep '"name\|version\|autor":' "{}" | uniq
//        case firefox = "cat /Users/*/Library/Application\\ Support/Firefox/Profiles/*/extensions.json"
        case firefox = "find ~/Library/Application\\ Support/Firefox/Profiles/ -type f -name \"extensions.json\" -print0 | xargs -I {} -0 grep \'\' \"{}\" | uniq"
        //case systemExtensionUnloaded = "systemextensionsctl list | grep 'activated disabled' | awk '{print $4}'"
    }
    
    struct Response {
        let query: String
        let data: String
    }
    
    // MARK: - Plugins
    func getThirdpartyExtensions() -> Result<[Extension],Error> {
        getAllPlugins().map{$0.filter{$0.vendor != "Apple"}}
    }
    
    private func getAllPlugins() -> Result<[Extension],Error> {
        let pluginResult: Result<Plugins,Error> = requestModel.runQuery(Query.plugin.rawValue)
        return pluginResult.map{ $0.list }
    }
    
    // MARK: - System Extensions
    
    private func getAllSystemExtensions() -> Result<SystemExtensions,Error>{
        requestModel.runQuery(Query.systemExtension.rawValue)
    }
    
    func getNetworkExtensions() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{$0.network}
    }
    
    func getSystemExtensionsUnloaded() -> Result<[Extension],Error>{
        getAllSystemExtensions().map{ items in
            let all = items.network + items.others
            return all.filter{!$0.status}
        }
    }
    
    func getOtherExtensions() -> Result<[Extension],Error> {
        getAllSystemExtensions().map{$0.others}
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
                    let item = Extension(name: $0.name)
                    item.vendor = $0.vendor
                    item.type = "Firefox Extension"
                    item.status = $0.active
                    item.path = $0.path
                    item.version = $0.version
                    return item
                }
                return .success(extensions)
            } catch {
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }
    
    // MARK: - All
    func getAllExtensions() -> Result<[Extension],Error> {
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
