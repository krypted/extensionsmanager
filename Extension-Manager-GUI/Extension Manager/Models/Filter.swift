import Foundation

struct Filter {
    let all: Bool
    let thirdparty: Bool
    let network: Bool
    let system: Bool
    let unloaded: Bool
    let googleChrome: Bool
    let microsoftEdge: Bool
    let fireFox: Bool
    
    init(all: Bool, thirdparty: Bool, network: Bool, system: Bool, unloaded: Bool, googleChrome: Bool, microsoftEdge: Bool, fireFox: Bool) {
        self.all = all
        self.thirdparty = thirdparty
        self.network = network
        self.system = system
        self.unloaded = unloaded
        self.googleChrome = googleChrome
        self.microsoftEdge = microsoftEdge
        self.fireFox = fireFox
    }
}
