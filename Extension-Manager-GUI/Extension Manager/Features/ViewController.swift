//
//  ViewController.swift
//  extensionsman
//
//  Created by Charles Edge on 09/01/2023.
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
        static var minimunSize: CGSize { CGSize(width: 1000, height: 550)}
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
    @IBOutlet weak var googleChrome: NSSwitch!
    @IBOutlet weak var microsoftEdge: NSSwitch!
    @IBOutlet weak var fireFox: NSSwitch!
    @IBOutlet weak var message: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!
    
    private let store = ExtensionStore(requestModel: RequestModel())
    
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
        
        searchField.delegate = self
        
        loadData()
    }
    
    @IBAction func valueChanged(_ sender: NSSwitch) {
        loadData()
    }
    
    @IBAction func refresh(_ sender: NSButton) {
        loadData()
    }
    
    private func loadData() {
        switch store.getExtensions(filter: getFilter(), query: getQuery(), sort: getSort()) {
        case .success(let items):
            extensionList = items
        case .failure(let error):
            message.stringValue =  error.localizedDescription
            message.isHidden = false
        }
    }
    
    private func getQuery() -> String {
        searchField.stringValue
    }
    
    private func getSort() -> Sort {
        let column = tableView.sortDescriptors.first
        let type = SortType(value: column?.key ?? "")
        return Sort(type: type ?? .name, acending: column?.ascending ?? true)
    }
    
    private func getFilter() -> Filter {
        return Filter(all: all.state == .on, thirdparty: thirdparty.state == .on, network: network.state == .on, system: system.state == .on, unloaded: unloaded.state == .on, googleChrome: googleChrome.state == .on, microsoftEdge: microsoftEdge.state == .on, fireFox: fireFox.state == .on)
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
            text = extensionItem.getStatusDescription()
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
    
    func tableView(_ tableView: NSTableView, sortDescriptorsDidChange oldDescriptors: [NSSortDescriptor]) {
        extensionList = store.changeSorting(sort: getSort())
    }
}

extension ViewController: NSSearchFieldDelegate {

    func controlTextDidChange(_ obj: Notification) {
        extensionList = store.changeQuery(query: getQuery())
    }
}
