//
//  JamfSelfServiceParser.swift
//  Jamf Switcher
//
//  Created by Richard Mallion on 21/06/2021.
//  Copyright © 2021 dataJAR. All rights reserved.
//

import Foundation


class JamfSelfServiceParser: NSObject, XMLParserDelegate {
    
    let xmlData: Data
    var foundCharacters = ""
    
    var foundObject = false
    var foundBookMark = false
    var foundURL = false
    var foundName = false
    var foundDescription = false
    var addInstance = false
    
    var name = ""
    var url = ""
    var jssdescription = ""

    var jssInstances = [JSS]()
    var jssInstance = JSS(name: "", url: "")

    init(xmlData: Data ) {
        self.xmlData = xmlData
    }
    
    func startParsing() {
        jssInstances = [JSS]()
        let myParser = XMLParser(data: xmlData)
        myParser.delegate = self
        myParser.parse()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        foundCharacters = ""
       if elementName.lowercased() == "object" {
            foundBookMark = false
            foundURL = false
            foundName = false
            foundDescription = false
            jssdescription = ""
            name = ""
            url = ""
            addInstance = true
            foundObject = true
        }
        
        if attributeDict["type"] == "SSBOOKMARK"{
            foundBookMark = true
        }
        
        if  elementName.lowercased() == "attribute" &&  attributeDict["name"] == "url" {
            foundURL = true
        }
        
        if elementName.lowercased() == "attribute" &&   attributeDict["name"] == "name" {
            foundName = true
        }
        
        if elementName.lowercased() == "attribute" &&  attributeDict["name"] == "jssdescription" {
            foundDescription = true
        } else if elementName.lowercased() == "attribute" &&  attributeDict["name"] == "serverdescription" {
            foundDescription = true
        }
        
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters = foundCharacters + string
        if foundObject && foundBookMark {
            if foundURL && url == "" {
                if foundCharacters.last == "/" {
                    url = String(foundCharacters.dropLast())
                } else {
                    url = foundCharacters
                }
            }
            
            if foundName && name == "" {
                name = foundCharacters
                name = name.replacingOccurrences(of: " - ", with: " ")
                name = name.replacingOccurrences(of: "\\u2600", with: "&")
            }
            
            if foundDescription && jssdescription == "" {
                jssdescription = foundCharacters
            }
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if jssdescription.lowercased().contains("jamf") || jssdescription.lowercased().contains("jps") || jssdescription.lowercased().contains("jss"){
                if foundDescription && foundURL && foundName && addInstance {
                    let foundInstance = JSS(name: name, url: url)
                    jssInstances.append(foundInstance)
                    addInstance = false
                }
            }
    }

}
