//
//  ViewController.swift
//  Jamf Switcher
//
//  Copyright © 2020 dataJAR. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    //Location of Service Service files for Jamf Pro 10.29 and below
    let managedPluginsPath =  "/Library/Application Support/JAMF/Self Service/Managed Plug-ins/"
    
    let appDelegate = NSApplication.shared.delegate as! AppDelegate
    let keyChainService = "uk.co.dataJAR.JamfSwitcher"
    
    //Location of Service Service files for Jamf Pro 10.30 and above
    let jamfSelfServiceCocoaAppCDURL = URL(fileURLWithPath: NSString(string: "~/Library/Application Support/com.jamfsoftware.selfservice.mac/CocoaAppCD.storedata").expandingTildeInPath)


    var apiKey = ""
    var continueProcessingPolices = true
    var currentJJSCounter = 0
    var dataToShow: [JSS] = []
    var filteredDataToShow: [JSS] = []
    var flushPolicies = false
    var itemsSelected = -1
    var jssCount = 0
    var policyReport = [String]()
    var policyToFind = ""
    var processedJSSCount = 0
    
    var jamfLogic = JamfLogic()
    var policyLogic = PolicyLogic()

    @IBOutlet weak var myTableView: NSTableView!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var progressView: NSBox!
    @IBOutlet weak var progressViewLabel: NSTextField!
    @IBOutlet weak var searchField: NSSearchField!

    @IBAction func cancelPolicy(_ sender: Any) {
        continueProcessingPolices = false
        searchField.isEnabled = true
    }

    @IBAction func showJSS(_ sender: Any) {
        webJSS()
    }
    
    @IBAction func refresh(_ sender: Any) {
        searchField.stringValue = ""
        if isCocoaAppCD() {
            //Jamf Pro 10.30 and above being used
            loadDataV2()
        } else {
            //Jamf Pro 10.29 and below being used
            loadData()
        }

    }
    
    @IBAction func showHelp(_ sender: Any) {
        NSWorkspace.shared.open(URL(string: "https://github.com/dataJAR/Jamf-Switcher")!)
    }
    
    @IBAction func exportJSS(_ sender: Any) {
        exportJSSList()
    }
    
    func exportJSSList() {
        let fileName = "Jamf Switcher Export"
        var csvText = ""
        for jss in filteredDataToShow {
            let newLine = "\"\(jss.name)\"" + "," + "\"\(jss.url)\"" + "\n"
            csvText.append(newLine)
        }
        saveToLocation(fileName: fileName, data: csvText)
    }

    func saveToLocation(fileName: String, data: String) {
        let panel = NSSavePanel()
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        searchField.isEnabled = true
        panel.canCreateDirectories = true
        panel.allowedFileTypes = ["csv"]
        panel.canSelectHiddenExtension = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = fileName + " - " + format.string(from: date)
        panel.directoryURL = getDocumentsDirectory()
        
        panel.beginSheetModal(for: self.view.window!) { (result) -> Void in
            if result.rawValue == NSFileHandlingPanelOKButton
            {
                guard let url = panel.url else { return }
                do {
                    try data.write(to: url, atomically: true, encoding: String.Encoding.utf8)
                    DispatchQueue.main.async(){
                    }
                } catch {
                    print (error.localizedDescription)
                    DispatchQueue.main.async(){
                    }
                }
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }


    func webJSS() {
        itemsSelected = myTableView.selectedRow
        guard itemsSelected >= 0 else { return }
        let stringSelected = filteredDataToShow[itemsSelected]
        let url = URL(string: stringSelected.url)
        NSWorkspace.shared.open(url!)
        myTableView.deselectRow(itemsSelected)
    }

    func processSelection() {
        let stringSelected = filteredDataToShow[itemsSelected]
        let url = stringSelected.url.replacingOccurrences(of: "/?failover", with: "")
        let userDefaultsValue = UserDefaults(suiteName: "com.jamfsoftware.jss")
        userDefaultsValue?.set(true, forKey: "allowInvalidCertificate")
        userDefaultsValue?.set(url, forKey: "url")
        myTableView.deselectRow(itemsSelected)
    }

    // MARK: Jamf Pro 10.29 and below
    func loadData() {
        //For Jamf Pro 10.29 and below
        dataToShow = []
        let listOfPlists = getListOfPlists()
        let arrayOfPlists = readPropertyList(listOfPlists: listOfPlists)
        for plist in arrayOfPlists {
            if let isJSS = plist["subtitle"] {
                if isJSS as! String  == "JSS" {
                    var companyName = plist["title"] as! String
                    companyName = companyName.replacingOccurrences(of: " - ", with: " ")
                    let url = plist["url"] as! String
                    let foundJSS = JSS(name: companyName, url: url)
                    dataToShow.append(foundJSS)
                }
            }
        }
        dataToShow = dataToShow.sorted { $0.name.lowercased()  < $1.name.lowercased() }
        filteredDataToShow = dataToShow
        myTableView.reloadData()
        if dataToShow.count > 0 {
            appDelegate.showJSSMenuItem.isEnabled = false
            appDelegate.exportJSSItem.isEnabled = true
            appDelegate.findPolicyJSSItem.isEnabled = true
            appDelegate.flushPolicyJSSItem.isEnabled = true
        } else {
            appDelegate.showJSSMenuItem.isEnabled = false
            appDelegate.exportJSSItem.isEnabled = false
            appDelegate.findPolicyJSSItem.isEnabled = false
            appDelegate.flushPolicyJSSItem.isEnabled = false
        }
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

    
    
    // MARK: Jamf Pro 10.30 and above
    
    
    func parseData(fileURL: URL) {
        //Jamf 10.30+
        if FileManager.default.fileExists(atPath: fileURL.path) {
            if let data = try? Data(contentsOf: fileURL) {
                let myParser = JamfSelfServiceParser(xmlData: data)
                myParser.startParsing()
                dataToShow = myParser.jssInstances
                dataToShow = dataToShow.sorted { $0.name.lowercased()  < $1.name.lowercased() }
                filteredDataToShow = dataToShow
                myTableView.reloadData()
            }
        } else {
            //File Does not exist
        }
    }
    

    
    func loadDataV2() {
        //For Jamf Pro 10.30 and above
        parseData(fileURL: jamfSelfServiceCocoaAppCDURL)
        appDelegate.showJSSMenuItem.isEnabled = false
        if dataToShow.count > 0 {
            appDelegate.exportJSSItem.isEnabled = true
            appDelegate.findPolicyJSSItem.isEnabled = true
            appDelegate.flushPolicyJSSItem.isEnabled = true
        } else {
            appDelegate.exportJSSItem.isEnabled = false
            appDelegate.findPolicyJSSItem.isEnabled = false
            appDelegate.flushPolicyJSSItem.isEnabled = false
        }
    }
    
    
    func isCocoaAppCD() -> Bool {
        if FileManager.default.fileExists(atPath: jamfSelfServiceCocoaAppCDURL.path) {
            return true
        } else {
            return false
        }
    }
    
        
    override func viewDidAppear() {
        if isCocoaAppCD() {
            //Jamf Pro 10.30 and above being used
            loadDataV2()
        } else {
            //Jamf Pro 10.29 and below being used
            loadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        appDelegate.exportJSSItem.target = self
        appDelegate.exportJSSItem.isEnabled = false
        appDelegate.findPolicyJSSItem.target = self
        appDelegate.findPolicyJSSItem.isEnabled = false
        appDelegate.flushPolicyJSSItem.target = self
        appDelegate.flushPolicyJSSItem.isEnabled = false
        appDelegate.showJSSMenuItem.target = self
        appDelegate.showJSSMenuItem.isEnabled = false
        myTableView.delegate = self
        myTableView.dataSource = self
        searchField.delegate = self
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

    // MARK: Policy Flush
    @IBAction func flushPolicySearch(_ sender: Any) {
        flushPolicies = true
        continueProcessingPolices = true
        searchField.isEnabled = false
        progressViewLabel.stringValue = "Flushing policies"
        processPolices()
    }

//    func flushMatchingPolicies(jssURL: String, apiKey: String , id: Int ) {
//        var checkedJSSURL = jssURL
//        if checkedJSSURL.suffix(1) == "/" {
//            checkedJSSURL = String(jssURL.dropLast())
//        }
//        let jssURLQuery = checkedJSSURL + "/JSSResource/logflush/policies/id/\(id)/interval/Zero+Days"
//        let url = URL(string: jssURLQuery)!
//        var request = URLRequest(url: url)
//        request.httpMethod = "DELETE"
//        request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
//        request.setValue("application/xml; charset=utf-8", forHTTPHeaderField: "Accept")
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = ["Authorization" : "Basic \(apiKey)", "Content-Type" : "application/xml", "Accept" : "application/xml"]
//
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            var responseFromJSS: HTTPURLResponse = HTTPURLResponse()
//            if let httpResponse = response as? HTTPURLResponse {
//                responseFromJSS = httpResponse
//            }
//
//            guard error == nil && ( responseFromJSS.statusCode == 200 || responseFromJSS.statusCode == 201 ) else {
//                DispatchQueue.main.async(){
//                        DispatchQueue.main.async(){
//                        }
//                }
//                return
//            }
//            DispatchQueue.main.async(){
//                    DispatchQueue.main.async(){
//                    }
//            }
//        }
//        task.resume()
//    }

    // MARK: Policy Find
    @IBAction func getPolicySearch(_ sender: Any) {
        continueProcessingPolices = true
        flushPolicies = false
        searchField.isEnabled = false
        progressViewLabel.stringValue = "Searching policies"
        processPolices()
    }

    func processPolices() {
        var answer: (String, String, String)
        if flushPolicies {
            answer = showFindAlert(title: "Jamf Switcher wants to use your credentials.", question: "Please enter your name, password and the policy search term.\r\rNOTE: This will flush any found polices. Please make sure the search term is accurate. if in doubt try a normal search first.")
        } else {
            answer = showFindAlert(title: "Jamf Switcher wants to use your credentials.", question: "Please enter your name, password and the policy search term.")
        }
        if answer.0 != "" && answer.1 != "" && answer.2 != "" {
            apiKey = createAPIKeyfromUser(user: answer.0, password: answer.1)
            policyToFind = answer.2
            jssCount = filteredDataToShow.count
            currentJJSCounter = 0
            processedJSSCount = 0
            policyReport = [String]()
            self.policyReport.append("Instance Name, URL , Result, Status")
            progressView.animator().alphaValue = 0.0
            progressView.wantsLayer = true
            NSAnimationContext.runAnimationGroup({ (context) in
                context.duration = 0.2
                context.allowsImplicitAnimation = true
                self.progressView.animator().alphaValue = 1.0
                self.progressView.isHidden = false
                self.progressIndicator.minValue = 1
                self.progressIndicator.maxValue = Double(filteredDataToShow.count)
                self.progressIndicator.doubleValue = 1
            }, completionHandler:{
            })
            processOneCompany(jssURL: filteredDataToShow[currentJJSCounter].url, row: currentJJSCounter, apiKey: apiKey)
        }
    }

    func processOneCompany(jssURL: String, row: Int, apiKey: String) {
        guard continueProcessingPolices else {
            progressView.isHidden = true
            return
        }
        findMatchingPoliciesV3(jssURL: jssURL, row: row, apiKey: apiKey)
        currentJJSCounter = currentJJSCounter + 1
        self.progressIndicator.doubleValue = Double(currentJJSCounter)
        if currentJJSCounter < jssCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100) , execute: {
                self.processOneCompany(jssURL: self.filteredDataToShow[self.currentJJSCounter].url, row: self.currentJJSCounter, apiKey: self.apiKey)
            })
        }
    }
    
    func processJSS(){
        if self.processedJSSCount == self.jssCount {
            let csvText = self.policyReport.joined(separator: "\n")
            DispatchQueue.main.async {
                self.progressView.isHidden = true
                let fileName = "Policy Search - " + self.policyToFind
                self.saveToLocation(fileName: fileName, data: csvText)
            }
        }
    }
    
    func savePolicies(csvText: String){
        DispatchQueue.main.async {
            self.progressView.isHidden = true
            if self.flushPolicies {
                let fileName = "Policy Flush - " + self.policyToFind
                self.saveToLocation(fileName: fileName, data: csvText)
            } else {
                let fileName = "Policy Search - " + self.policyToFind
                self.saveToLocation(fileName: fileName, data: csvText)
            }
        }
    }

    
    
    //MARK: findMatchingPolices V3
    func findMatchingPoliciesV3(jssURL: String, row: Int, apiKey: String) {
        let checkedJSSURL = ParseURL(url: jssURL)
        
        //MARK: Find ALL Policies
        jamfLogic.findAllPolicies(jamfServerURL: checkedJSSURL, apiKey: apiKey){ response in
            self.processedJSSCount = self.processedJSSCount + 1
            //print("processed - \(self.processedJSSCount) of \(self.jssCount)")
            
            switch response {
                
            case .success(let foundPolicies):
                //MARK: Process Policies
                self.policyLogic.processPolicy(foundPolicies: foundPolicies, policyToFind: self.policyToFind, checkedJSSURL: checkedJSSURL, apiKey: apiKey, flushPolicies: self.flushPolicies, instanceName: self.filteredDataToShow[row].name) { result in
                    switch result {
                        
                    case .success(let report):
                        self.policyReport.append(contentsOf: report)
                        if self.processedJSSCount == self.jssCount {
                            let csvText = self.policyReport.joined(separator: "\n")
                            self.savePolicies(csvText: csvText)
                        }
                    case .failure(let error):
                        self.policyReport.append("\"\(self.filteredDataToShow[row].name)\"" + "," + checkedJSSURL + "," + "\"Error. \(error.statusCode) - \(error.localizedDescription)\"" + "," + "N/A")
                        if self.processedJSSCount == self.jssCount {
                            let csvText = self.policyReport.joined(separator: "\n")
                            self.savePolicies(csvText: csvText)
                        }
                    }
                }
               
                break
            case .failure(let error):
                self.policyReport.append("\"\(self.filteredDataToShow[row].name)\"" + "," + checkedJSSURL + "," + "\"Error. \(error.statusCode) - \(error.localizedDescription)\"" + "," + "N/A")
                if self.processedJSSCount == self.jssCount {
                    let csvText = self.policyReport.joined(separator: "\n")
                    self.savePolicies(csvText: csvText)
                }
                break
            }
        }
    }
  
    private func ParseURL(url: String) -> String {
        var checkedJSSURL = url
        if checkedJSSURL.contains("?failover") {
            checkedJSSURL = checkedJSSURL.replacingOccurrences(of: "?failover", with: "")
        }
        if checkedJSSURL.suffix(1) == "/" {
            checkedJSSURL = String(checkedJSSURL.dropLast())
        }
//        print(checkedJSSURL)
        return checkedJSSURL
    }
    
//    func findMatchingPolicies(jssURL: String, row: Int, apiKey: String) {
//        var checkedJSSURL = jssURL
//        if checkedJSSURL.suffix(1) == "/" {
//            checkedJSSURL = String(jssURL.dropLast())
//        }
//        let jssURLQuery = checkedJSSURL + "/JSSResource/policies"
//        let url = URL(string: jssURLQuery)!
//        var request = URLRequest(url: url)
//        request.httpMethod = "GET"
//        request.setValue("Basic \(apiKey)", forHTTPHeaderField: "Authorization")
//        request.setValue("application/json", forHTTPHeaderField: "Accept")
//        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
//            self.processedJSSCount = self.processedJSSCount + 1
//            guard error == nil && (response as? HTTPURLResponse)?.statusCode == 200 else {
//                if !self.flushPolicies {
//                    var statusCode = ""
//                    let response = response as? HTTPURLResponse
//                    if let sc = response {
//                        statusCode = String(sc.statusCode)
//                    }
//                    self.policyReport.append("\"\(self.filteredDataToShow[row].name)\"" + "," + jssURL + "," + "" + "," + "\"Error. \(statusCode)\"")
//                }
//                if self.processedJSSCount == self.jssCount {
//                    let csvText = self.policyReport.joined(separator: "\n")
//                    DispatchQueue.main.async {
//                        self.progressView.isHidden = true
//                        let fileName = "Policy Search - " + self.policyToFind
//                        self.saveToLocation(fileName: fileName, data: csvText)
//                    }
//                }
//                return
//            }
//            if let data = data {
//                let decoder = JSONDecoder()
//                if let myPolices = try? decoder.decode(Policies.self, from: data) {
//                    let foundPolices = myPolices.policies.filter{$0.name.lowercased().contains(self.policyToFind.lowercased())}
//                    var foundPolicesFormated = ""
//                    for policy in foundPolices {
//                        foundPolicesFormated = foundPolicesFormated + policy.name + "\r"
//                    }
//                    if foundPolices.count > 0 {
//                        if self.flushPolicies {
//                            for policy in foundPolices {
//                                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100) , execute: {
//                                    self.flushMatchingPolicies(jssURL: jssURL, apiKey: apiKey, id: policy.id  )
//                                })
//                            }
//                        }
//                        if self.flushPolicies {
//                            self.policyReport.append("\"\(self.filteredDataToShow[row].name)\"" + "," + jssURL + "," + "\"\(foundPolicesFormated)\"" + "," + "Flushed")
//                        } else {
//                            self.policyReport.append("\"\(self.filteredDataToShow[row].name)\"" + "," + jssURL + "," + "\"\(foundPolicesFormated)\"" + "," + "Found")
//                        }
//                    } else {
//                            self.policyReport.append("\"\(self.filteredDataToShow[row].name)\"" + "," + jssURL + "," + "" + ","  + "Not Found")
//                    }
//                    if self.processedJSSCount == self.jssCount {
//                        let csvText = self.policyReport.joined(separator: "\n")
//                        DispatchQueue.main.async {
//                            self.progressView.isHidden = true
//                            if self.flushPolicies {
//                                let fileName = "Policy Flush - " + self.policyToFind
//                                self.saveToLocation(fileName: fileName, data: csvText)
//                            } else {
//                                let fileName = "Policy Search - " + self.policyToFind
//                                self.saveToLocation(fileName: fileName, data: csvText)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//        task.resume()
//    }

    func createAPIKeyfromUser(user: String, password: String) -> String {
        let loginData = String(format: "%@:%@", user, password).data(using: String.Encoding.utf8)!
        let base64LoginData = loginData.base64EncodedString()
        return base64LoginData
    }

    func showFindAlert(title: String, question: String) ->  (String, String, String) {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")      // 1st button
        alert.addButton(withTitle: "Cancel")  // 2nd button
        alert.messageText = title
        alert.informativeText = question
        let unameField = NSTextField(frame: NSRect(x: 0, y: 54, width: 250, height: 22))
        let passField = NSSecureTextField(frame: NSRect(x: 0, y: 28, width: 250, height: 22))
        let searchField = NSTextField(frame: NSRect(x: 0, y: 2, width: 250, height: 22))
        if let str = KeychainService.loadPassword(service: keyChainService, account: "passcode") {
            passField.stringValue = str
        }
        if let str = KeychainService.loadPassword(service: keyChainService, account: "username") {
            unameField.stringValue = str
        }
        unameField.nextKeyView = passField
        passField.nextKeyView = searchField
        searchField.nextKeyView = unameField
        let stackViewerTextFields = NSStackView(frame: NSRect(x: 70, y: 0, width: 200, height: 80))
        stackViewerTextFields.addSubview(searchField)
        stackViewerTextFields.addSubview(passField)
        stackViewerTextFields.addSubview(unameField)
        let unameLabel = NSTextField(labelWithString: "Name:")
        unameLabel.frame = NSRect(x: 0, y: 54, width: 200, height: 22)
        unameLabel.isEditable = false
        unameLabel.isSelectable = false
        let passLabel = NSTextField(labelWithString: "Password:")
        passLabel.frame = NSRect(x: 0, y: 28, width: 200, height: 22)
        passLabel.isEditable = false
        passLabel.isSelectable = false
        let searchLabel = NSTextField(labelWithString: "Search:")
        searchLabel.frame = NSRect(x: 0, y: 2, width: 200, height: 22)
        searchLabel.isEditable = false
        searchLabel.isSelectable = false
        let stackViewerLabels = NSStackView(frame: NSRect(x: 0, y: 0, width: 200, height: 80))
        stackViewerLabels.addSubview(unameLabel)
        stackViewerLabels.addSubview(passLabel)
        stackViewerLabels.addSubview(searchLabel)
        let stackViewerMaster = NSStackView(frame: NSRect(x: 0, y: 0, width: 400, height: 80))
        stackViewerMaster.addSubview(stackViewerTextFields)
        stackViewerMaster.addSubview(stackViewerLabels)
        alert.accessoryView = stackViewerMaster
        alert.window.initialFirstResponder = searchField
        let response: NSApplication.ModalResponse = alert.runModal()
        if (response == NSApplication.ModalResponse.alertFirstButtonReturn) {
            if let _ = KeychainService.loadPassword(service: keyChainService, account: "passcode") {
                KeychainService.updatePassword(service: keyChainService, account: "passcode", data: passField.stringValue)
            }
            else {
                KeychainService.savePassword(service: keyChainService, account: "passcode", data: passField.stringValue)
            }
            if let _ = KeychainService.loadPassword(service: keyChainService, account: "username") {
                KeychainService.updatePassword(service: keyChainService, account: "username", data: unameField.stringValue)
            }
            else {
                KeychainService.savePassword(service: keyChainService, account: "username", data: unameField.stringValue)
            }
            return (unameField.stringValue, passField.stringValue, searchField.stringValue)
        } else {
            return ("", "", "")
        }
    }
}

// MARK: TableView Functions
extension ViewController: NSTableViewDataSource {
func numberOfRows(in tableView: NSTableView) -> Int {
    return filteredDataToShow.count
}
}

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        if tableColumn == tableView.tableColumns[0] {
            text = filteredDataToShow[row].name
            text = text + " - "
            text = text + filteredDataToShow[row].url
        }
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "myCell"), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let _ = self.myTableView.selectedRowIndexes.last {
            appDelegate.showJSSMenuItem.isEnabled = true
        } else {
            appDelegate.showJSSMenuItem.isEnabled = false
        }
       
    }
}

// MARK: Search Functions
extension ViewController: NSSearchFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        if let searchField = obj.object as? NSTextField {
            if searchField.stringValue.isEmpty {
                filteredDataToShow = dataToShow
            } else {
                filteredDataToShow = dataToShow.filter { $0.name.lowercased().contains(searchField.stringValue.lowercased()) || $0.url.lowercased().contains(searchField.stringValue.lowercased()) }
            }
            if filteredDataToShow.isEmpty {
                appDelegate.exportJSSItem.isEnabled = false
                appDelegate.findPolicyJSSItem.isEnabled = false
                appDelegate.flushPolicyJSSItem.isEnabled = false

            } else {
                appDelegate.exportJSSItem.isEnabled = true
                appDelegate.findPolicyJSSItem.isEnabled = true
                appDelegate.flushPolicyJSSItem.isEnabled = true
            }
            myTableView.reloadData()
        }
    }
}
