//
//  ViewController.swift
//  extensionsman
//
//

import Cocoa

extension NSView {
    func setSize(greaterThanEqualTo size: CGSize)  {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(greaterThanOrEqualToConstant: size.width).isActive = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: size.height).isActive = true
    }
}

struct R {
    struct Dimension {
        static var screenSize: CGSize {
            let isFullScreen = NSApplication.shared.windows.first?.styleMask.contains(.fullScreen) ?? false
            if let size = NSScreen.main?.visibleFrame.size, !isFullScreen {
                return CGSize(width: size.width, height: size.height-20)
            }else {
                return  CGSize(width: 970, height: 700)
            }
        }
        static var minimunSize: CGSize { CGSize(width: 800, height: 550)}
    }
    
    struct Color {
        static let grey = NSColor(named: "grey")
        static let text = NSColor.black
    }
}

class ViewController: NSViewController {
    
    @IBOutlet weak var all: NSSwitch!
    @IBOutlet weak var thirdparty: NSSwitch!
    @IBOutlet weak var network: NSSwitch!
    @IBOutlet weak var system: NSSwitch!
    @IBOutlet weak var unloaded: NSSwitch!
    @IBOutlet weak var message: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    private let store = ExtensionStore()
    private var extensionList = [Extension]() {
        didSet {
            if extensionList.isEmpty {
                message.stringValue =  "NO ITEMS FOUND. TRY AGIAN WITH DIFFERENT FILTER"
                message.isHidden = false
            } else {
                message.isHidden = true
            }
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.appearance = NSAppearance(named: .vibrantLight)
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.white.cgColor
        self.view.setSize(greaterThanEqualTo: R.Dimension.minimunSize)
        
        message.isBordered = false
        message.isEditable = false
        message.isSelectable = false
        
        tableView.dataSource = self
        tableView.delegate = self
        
        loadData()
    }
    
    @IBAction func valueChanged(_ sender: NSSwitch) {
        loadData()
    }
    
    @IBAction func refresh(_ sender: NSButton) {
        loadData()
    }
    
    private func loadData() {
        switch getExtensions() {
        case .success(let items):
            extensionList = items
        case .failure(let error):
            message.stringValue =  error.localizedDescription
            message.isHidden = false
        }
    }
    
    private func getExtensions() -> Result<[Extension],Error> {
        
        // show all
        guard all.state == .off else { return store.getAllExtensions() }
        
        var extensionList = [Extension]()
        
        if thirdparty.state == .on {
            switch store.getThirdpartyExtensions() {
            case .success(let items):
                extensionList.append(contentsOf: items)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        if network.state == .on {
            switch store.getNetworkExtensions() {
            case .success(let items):
                extensionList.append(contentsOf: items)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        if system.state == .on {
            switch store.getOtherExtensions() {
            case .success(let items):
                extensionList.append(contentsOf: items)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        
        if unloaded.state == .on {
            switch store.getSystemExtensionsUnloaded() {
            case .success(let items):
                extensionList.append(contentsOf: items)
            case .failure(let error):
                return .failure(error)
            }
        }
        
        return .success(extensionList)
    }
}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return extensionList.count
    }
}

extension ViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let reuseId = NSUserInterfaceItemIdentifier(rawValue: "NameCell")
        let extensionItem = extensionList[row]
        
        let text: String
        if tableColumn == tableView.tableColumns[0] {
            text = extensionItem.name
        } else if tableColumn == tableView.tableColumns[1] {
            text = extensionItem.vendor
        } else if tableColumn == tableView.tableColumns[2] {
            text = extensionItem.type
        } else if tableColumn == tableView.tableColumns[3] {
            text = extensionItem.status ? "Installed" : "Not Installed"
        } else if tableColumn == tableView.tableColumns[4] {
            text = extensionItem.path
        } else if tableColumn == tableView.tableColumns[5] {
            text = extensionItem.version
        } else if tableColumn == tableView.tableColumns[6] {
            text = extensionItem.sdk
        } else {
            text = ""
        }
        
        if let cell = tableView.makeView(withIdentifier: reuseId, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }else {
            return nil
        }
    }
}
