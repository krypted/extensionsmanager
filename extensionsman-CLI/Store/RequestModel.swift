import Foundation

class RequestModel {
    
    init() { }
    
    // MARK: - Data
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
    
    @discardableResult private func safeShell(_ command: String) throws -> String {
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
