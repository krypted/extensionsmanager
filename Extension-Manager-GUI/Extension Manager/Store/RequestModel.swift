import Foundation

class RequestModel {
    
    @discardableResult private func safeShell(_ command: String) throws -> String {
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
    
    func getData(query: String) -> Result<String,Error> {
        do {
            let data = try safeShell(query)
            return .success(data)
        }catch {
            return .failure(error)
        }
    }
    
    func runQuery<T>(_ query: String) -> Result<T,Error> where T: Parseable {
        getData(query: query).map{ T(string: $0) }
    }
}
