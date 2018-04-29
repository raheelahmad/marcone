//
//  Helpers.swift
//  marcone
//
//  Created by Raheel Ahmad on 3/1/18.
//

import Foundation
import SWXMLHash
import Debugging

typealias DBDict = [String: Any]
typealias JSON = [String: Any]


// MARK: Fetching & Parsing

enum ParsingError: Error, Debuggable {
    var reason: String {
        switch self { case .podcast(let reason, causes: _): return reason }
    }
    var identifier: String {
        return "failed parsing"
    }
    var possibleCauses: [String] {
        switch self { case .podcast(reason: _, let causes): return causes }
    }
    var suggestedFixes: [String] {
        return []
    }

    case podcast(reason: String, causes: [String])
}

// MARK: Parsing helper funcs

func elements(_ name: String, `in` xml: [XMLIndexer]) -> [XMLIndexer] {
    return xml.filter { $0.element?.name == name }
}

func value(_ name: String, `in` xml: [XMLIndexer]) -> String? {
    return xml.filter { $0.element?.name == name }.first?.element?.text
}

func values(_ name: String, `in` xml: [XMLIndexer]) -> [String] {
    return xml.filter { $0.element?.name == name }.flatMap { $0.element?.text }
}

func nestedValues(_ name: String, nestedName: String, nestedAttribute: String, `in` xml: [XMLIndexer]) -> [String] {
    let children = xml.filter { $0.element?.name == name }
    let result = children.flatMap { topChild in
        return topChild.children.filter {
            return $0.element?.name == nestedName
            }.map { (child: XMLIndexer) -> String? in
            let attrValue: String? = child.element?.value(ofAttribute: nestedAttribute)
            return attrValue
        }
    }
    return result.flatMap { $0 }
}

func attr(_ name: String, attr: String, `in` xml: [XMLIndexer]) -> String? {
    return xml.filter { $0.element?.name == name }.first?.value(ofAttribute: attr)
}

func attrs(_ name: String, attr: String, `in` xml: [XMLIndexer]) -> [String] {
    return xml.filter { $0.element?.name == name }.flatMap { $0.value(ofAttribute: attr) }
}
