//
//  ViewController.swift
//  Jamf Switcher
//
//  Copyright © 2019 dataJAR. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    let managedPluginsPath =  "/Library/Application Support/JAMF/Self Service/Managed Plug-ins/"
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    var dataToShow: [String] = []
    var filteredDataToShow: [String] = []
    var itemsSelected = -1

    @IBOutlet weak var myTableView: NSTableView!
    @IBOutlet weak var searchField: NSSearchField!

    @IBAction func showJSS(_ sender: Any) {
        webJSS()
    }
    
    @IBAction func refresh(_ sender: Any) {
        loadData()
    }
    
    @IBAction func showHelp(_ sender: Any?) {
        NSWorkspace.shared.open(URL(string: "https://github.com/dataJAR/Jamf-Switcher")!)
    }

    func webJSS() {
        itemsSelected = myTableView.selectedRow
        guard itemsSelected >= 0 else { return }
        let stringSelected = filteredDataToShow[itemsSelected]
        let stringArray = stringSelected.components(separatedBy: " - ")
        let url = URL(string: stringArray[1])
        NSWorkspace.shared.open(url!)
        myTableView.deselectRow(itemsSelected)
    }

    func processSelection() {
        let stringSelected = filteredDataToShow[itemsSelected]
        let stringArray = stringSelected.components(separatedBy: " - ")
        let url = stringArray[1].replacingOccurrences(of: "/?failover", with: "")
        let userDefaultsValue = UserDefaults(suiteName: "com.jamfsoftware.jss")
        userDefaultsValue?.set(true, forKey: "allowInvalidCertificate")
        userDefaultsValue?.set(url, forKey: "url")
        myTableView.deselectRow(itemsSelected)
    }

    func loadData() {
        dataToShow = []
        let listOfPlists = getListOfPlists()
        let arrayOfPlists = readPropertyList(listOfPlists: listOfPlists)
        for plist in arrayOfPlists {
            if let isJSS = plist["subtitle"]?.lowercased {
                if isJSS.contains("jamf") || isJSS.contains("jps") || isJSS.contains("jss") {
                    var companyName = plist["title"] as! String
                    companyName = companyName.replacingOccurrences(of: " - ", with: " ")
                    let url = plist["url"] as! String
                    let myString = companyName + " - " +  url
                    dataToShow.append(myString)
                }
            }
        }
        dataToShow = dataToShow.sorted { $0.lowercased()  < $1.lowercased() }
        filteredDataToShow = dataToShow
        myTableView.reloadData()
        appDelegate.showJSSMenuItem.isEnabled = false
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        NSApplication.shared.windows.first?.styleMask = .titled
        myTableView.delegate = self
        myTableView.dataSource = self
        searchField.delegate = self
        appDelegate.showJSSMenuItem.target = self
        appDelegate.showJSSMenuItem.isEnabled = false
        loadData()
    }

    func readPropertyList(listOfPlists: [String]) ->  [[String: AnyObject]] {
        var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
        var plistData: [String: AnyObject] = [:]
        var arrayOfPlists: [[String: AnyObject]] = []
        for plist in listOfPlists {
            let plistPath = managedPluginsPath + plist
            let plistXML = FileManager.default.contents(atPath: plistPath)!
            do {
                plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as! [String:AnyObject]
                arrayOfPlists.append(plistData)
            } catch {
                print("Error reading plist: \(error), format: \(propertyListFormat)")
            }
        }
        return arrayOfPlists
    }

    func getListOfPlists() -> [String]{
        do {
            let filePaths = try FileManager.default.contentsOfDirectory(atPath: managedPluginsPath)
            let plistFilePaths = filePaths.filter{$0.contains(".plist")}
            return plistFilePaths
        }
        catch {
            return[]
        }
    }

    func openJamfApp() {
        let dialog = NSOpenPanel();
        dialog.message                 = "Please select a Jamf Pro Application:";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["app"];
        if FileManager.default.fileExists(atPath: "/Applications/Jamf Pro/") {
            dialog.directoryURL = URL(fileURLWithPath: "/Applications/Jamf Pro/")
        } else {
            dialog.directoryURL = URL(fileURLWithPath: "/Applications/")
        }
        
        if (dialog.runModal() == NSApplication.ModalResponse.OK) {
            let result = dialog.url
            if (result != nil) {
                let path = result!.path
                NSWorkspace.shared.open(URL(fileURLWithPath: path))
            }
        } else {
            return
        }
    }

    override func awakeFromNib() {
        myTableView.doubleAction = #selector(tableViewDoubleClick(_:))
    }

    @objc func tableViewDoubleClick(_ sender:AnyObject){
        rowSelected()
        if itemsSelected >= 0 {
            processSelection()
            openJamfApp()
        }
    }

    func rowSelected() {
        itemsSelected = myTableView.selectedRow
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 36 {
            rowSelected()
            if itemsSelected >= 0 {
                processSelection()
                openJamfApp()
            }
        }
    }
}

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredDataToShow.count
    }
}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = filteredDataToShow[row]
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "myCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
       appDelegate.showJSSMenuItem.isEnabled = true
    }
}

extension ViewController: NSSearchFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        if let searchField = obj.object as? NSTextField {
            if searchField.stringValue.isEmpty {
                filteredDataToShow = dataToShow
            } else {
                filteredDataToShow = dataToShow.filter { $0.lowercased().contains(searchField.stringValue.lowercased())}
            }
            myTableView.reloadData()
        }
    }
}
